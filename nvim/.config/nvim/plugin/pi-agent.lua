local PANE_WIDTH = 35

local current_pane_id = nil

local current_pane_exists = function()
  if not current_pane_id then
    return false
  end

  local output = vim.fn.system(string.format("tmux list-panes -F '#{pane_id}' | grep -w %s", current_pane_id))
  return vim.v.shell_error == 0 and #output > 0
end

local open_pi_agent = function()
  if current_pane_id and current_pane_exists() then
    return
  end

  local output = vim.fn.system(string.format("tmux split-window -d -h -f -p %d -F '#{pane_id}' -P -- pi", PANE_WIDTH))
  current_pane_id = vim.fn.trim(output)
end

local function ensure_pi_agent()
  if not current_pane_exists() then
    open_pi_agent()
  end
end

local function send_pi_agent_command(cmd)
  vim.fn.system(string.format("tmux send-keys -t %s '%s '", current_pane_id, cmd))
end

local function file_relative_path()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(file, ":.")
end

local append_line_to_pi_agent = function()
  ensure_pi_agent()

  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d", relative_file_path, line_num)

  send_pi_agent_command(command)
end

local append_selection_to_pi_agent = function()
  ensure_pi_agent()

  local visual_start_line = vim.fn.line("v")
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = math.min(visual_start_line, cursor_line)
  local end_line = math.max(visual_start_line, cursor_line)

  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d-%d", relative_file_path, start_line, end_line)

  send_pi_agent_command(command)
end

vim.keymap.set("n", "<c-a>", open_pi_agent, { desc = "Open Pi Agent" })
vim.keymap.set("n", "ga", append_line_to_pi_agent, { desc = "Send line to Pi Agent" })
vim.keymap.set("v", "ga", append_selection_to_pi_agent, { desc = "Send selection to Pi Agent" })
