-- Native Herdr/tmux split pane provider for claudecode.nvim.

local M = {}

local pane_id

local function in_herdr()
  return (vim.env.HERDR_PANE_ID or "") ~= ""
end

local function in_tmux()
  return (vim.env.TMUX or "") ~= ""
end

local function herdr(args)
  local bin = (vim.env.HERDR_BIN_PATH or "") ~= "" and vim.env.HERDR_BIN_PATH or "herdr"
  return vim.system(vim.list_extend({ bin }, args), { text = true }):wait()
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

  local out = tmux({ "list-panes", "-a", "-F", "#{pane_id}" })
  return vim.tbl_contains(vim.split(out.stdout or "", "\n", { trimempty = true }), pane_id)
end

local function focus_pane()
  if in_herdr() then
    herdr({ "pane", "focus", "--pane", vim.env.HERDR_PANE_ID, "--direction", "right" })
  else
    tmux({ "select-pane", "-t", pane_id })
  end
end

local function close_pane()
  if pane_alive() then
    if in_herdr() then
      herdr({ "pane", "close", pane_id })
    else
      tmux({ "kill-pane", "-t", pane_id })
    end
  end

  pane_id = nil
end

local function open_pane(cmd_string, env_table, focus)
  if pane_alive() then
    if focus then
      focus_pane()
    end

    return
  end

  local cwd = vim.fn.getcwd()

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
  else
    tmux({ "send-keys", "-t", pane_id, "-l", text })
    tmux({ "send-keys", "-t", pane_id, "Enter" })
  end
end

---claudecode.nvim terminal provider actions.
function M.setup() end

function M.is_available()
  return in_herdr() or in_tmux()
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
