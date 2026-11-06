-- Native herdr / herdr-app / tmux split pane provider for claudecode.nvim.

local M = {}

local pane_id
local terminal_id -- herdr-app only

local function in_herdr()
  return (vim.env.HERDR_PANE_ID or "") ~= ""
end

local function in_herdr_app()
  return (vim.env.HC_TERMINAL_ID or "") ~= ""
end

local function in_tmux()
  return (vim.env.TMUX or "") ~= ""
end

local function herdr(args)
  local bin = (vim.env.HERDR_BIN_PATH or "") ~= "" and vim.env.HERDR_BIN_PATH or "herdr"
  return vim.system(vim.list_extend({ bin }, args), { text = true }):wait()
end

local function app(cmd, args)
  return vim.system({ "herdr-app", "do", cmd, vim.json.encode(args) }, { text = true }):wait()
end

local function hc(args)
  return vim.system(vim.list_extend({ "hc" }, args), { text = true }):wait()
end

local function tmux(args)
  return vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
end

local function pane_alive()
  if not pane_id then
    return false
  end

  if in_herdr() then
    return herdr({ "pane", "get", pane_id }).code == 0
  end

  if in_herdr_app() then
    local res = hc({ "get", terminal_id, "--json" })
    local ok, decoded = pcall(vim.json.decode, res.stdout or "")
    return res.code == 0 and ok and decoded.state == "live"
  end

  local out = tmux({ "list-panes", "-a", "-F", "#{pane_id}" })
  return vim.tbl_contains(vim.split(out.stdout or "", "\n", { trimempty = true }), pane_id)
end

local function focus_pane()
  if in_herdr() then
    herdr({ "pane", "focus", "--pane", vim.env.HERDR_PANE_ID, "--direction", "right" })
  elseif in_herdr_app() then
    app("pane.focus", { pane = pane_id })
  else
    tmux({ "select-pane", "-t", pane_id })
  end
end

local function close_pane()
  if pane_alive() then
    if in_herdr() then
      herdr({ "pane", "close", pane_id })
    elseif in_herdr_app() then
      app("pane.close", { pane = pane_id })
    else
      tmux({ "kill-pane", "-t", pane_id })
    end
  end

  pane_id, terminal_id = nil, nil
end

local function open_pane(cmd_string, env_table, focus)
  if pane_alive() then
    if focus then
      focus_pane()
    end

    return
  end

  local cwd = vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()

  if in_herdr() then
    local args = { "pane", "split", "--current", "--direction", "right", "--cwd", cwd }
    for k, v in pairs(env_table) do
      vim.list_extend(args, { "--env", k .. "=" .. v })
    end

    local res = herdr(args)
    local ok, decoded = pcall(vim.json.decode, res.stdout or "")
    if not ok then
      return vim.notify("herdr split failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
    end

    pane_id = decoded.result.pane.pane_id
    herdr({ "pane", "run", pane_id, cmd_string })
    if focus then
      focus_pane()
    end
  elseif in_herdr_app() then
    local argv = { "env" }
    for k, v in pairs(env_table) do
      table.insert(argv, k .. "=" .. v)
    end
    vim.list_extend(argv, { "sh", "-c", cmd_string })

    local res = app("terminal.open", { argv = argv, folder = cwd, place = "right" })
    local ok, decoded = pcall(vim.json.decode, res.stdout or "")
    if not ok or decoded.error then
      return vim.notify("herdr-app split failed: " .. (res.stdout or "") .. (res.stderr or ""), vim.log.levels.ERROR)
    end

    pane_id, terminal_id = decoded.pane, decoded.terminal
    if not focus then
      app("pane.focus", { terminal = vim.env.HC_TERMINAL_ID })
    end
  else
    local args = { "split-window", "-h", "-P", "-F", "#{pane_id}", "-c", cwd }
    if not focus then
      table.insert(args, "-d")
    end
    for k, v in pairs(env_table) do
      vim.list_extend(args, { "-e", k .. "=" .. v })
    end

    table.insert(args, cmd_string)
    local res = tmux(args)
    if res.code ~= 0 then
      return vim.notify("tmux split failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
    end

    pane_id = vim.trim(res.stdout)
  end
end

---Type `text` into the Claude pane and submit it.
---@param text string
function M.send(text)
  if not pane_alive() then
    return vim.notify("Claude pane not open", vim.log.levels.WARN)
  end

  if in_herdr() then
    herdr({ "pane", "send-text", pane_id, text })
    herdr({ "pane", "send-keys", pane_id, "Enter" })
  elseif in_herdr_app() then
    hc({ "send", terminal_id, text })
  else
    tmux({ "send-keys", "-t", pane_id, "-l", text })
    tmux({ "send-keys", "-t", pane_id, "Enter" })
  end
end

---claudecode.nvim terminal provider actions.
function M.setup() end

function M.is_available()
  return in_herdr() or in_herdr_app() or in_tmux()
end

function M.open(cmd_string, env_table, _, focus)
  open_pane(cmd_string, env_table, focus ~= false)
end

M.close = close_pane

function M.simple_toggle(cmd_string, env_table)
  if pane_alive() then
    close_pane()
  else
    open_pane(cmd_string, env_table, true)
  end
end

M.toggle = M.simple_toggle

function M.focus_toggle(cmd_string, env_table)
  open_pane(cmd_string, env_table, true)
end

function M.ensure_visible() end

function M.get_active_bufnr()
  return nil
end

return M
