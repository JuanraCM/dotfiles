local PANE_WIDTH = 35
local AGENT_CMD = "claude"

local agent_ttys = function()
  local ttys = {}

  for line in vim.fn.system("ps -eo tty=,args="):gmatch("[^\n]+") do
    local tty, args = line:match("^(%S+)%s+(.*)$")
    local argv0 = args and args:match("^%S+")

    if tty and tty ~= "?" and argv0 and vim.fs.basename(argv0):match(AGENT_CMD) then
      ttys[tty] = true
    end
  end

  return ttys
end

local find_agent_pane = function()
  local ttys = agent_ttys()
  local output = vim.fn.system("tmux list-panes -F '#{pane_tty} #{pane_id}'")

  for line in output:gmatch("[^\n]+") do
    local pane_tty, pane_id = line:match("^(%S+)%s+(%S+)$")
    local tty = pane_tty and pane_tty:gsub("^/dev/", "")

    if tty and ttys[tty] then
      return pane_id
    end
  end

  return nil
end

local open_agent = function()
  local output = vim.fn.system(
    string.format("tmux split-window -d -h -f -p %d -F '#{pane_id}' -P -- %s", PANE_WIDTH, AGENT_CMD)
  )
  return vim.fn.trim(output)
end

local function ensure_agent()
  return find_agent_pane() or open_agent()
end

local function send_agent_command(pane_id, cmd)
  vim.fn.system(string.format("tmux send-keys -t %s '%s '", pane_id, cmd))
end

local function file_relative_path()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(file, ":.")
end

local append_line_to_agent = function()
  local pane_id = ensure_agent()

  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d", relative_file_path, line_num)

  send_agent_command(pane_id, command)
end

local append_selection_to_agent = function()
  local pane_id = ensure_agent()

  local visual_start_line = vim.fn.line("v")
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = math.min(visual_start_line, cursor_line)
  local end_line = math.max(visual_start_line, cursor_line)

  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d-%d", relative_file_path, start_line, end_line)

  send_agent_command(pane_id, command)
end

vim.keymap.set("n", "ga", append_line_to_agent, { desc = "Send line to AI Agent" })
vim.keymap.set("v", "ga", append_selection_to_agent, { desc = "Send selection to AI Agent" })
