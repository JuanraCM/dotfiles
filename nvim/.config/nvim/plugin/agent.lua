local claude = require("custom.claude")

local function file_relative_path()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(file, ":.")
end

local append_line_to_agent = function()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d", relative_file_path, line_num)

  claude.send_agent_command(command)
end

local append_selection_to_agent = function()
  local visual_start_line = vim.fn.line("v")
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = math.min(visual_start_line, cursor_line)
  local end_line = math.max(visual_start_line, cursor_line)

  local relative_file_path = file_relative_path()
  local command = string.format("@%s:%d-%d", relative_file_path, start_line, end_line)

  claude.send_agent_command(command)
end

vim.keymap.set("n", "ga", append_line_to_agent, { desc = "Send line to AI Agent" })
vim.keymap.set("v", "ga", append_selection_to_agent, { desc = "Send selection to AI Agent" })
