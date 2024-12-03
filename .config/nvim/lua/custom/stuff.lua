-- Creates a temporary lua sandbox buffer that executes on <C-x>
vim.api.nvim_create_user_command("Sandbox", function (_)
  local buf = vim.api.nvim_create_buf(true, false)

  vim.api.nvim_buf_set_name(buf, "Sandbox")
  vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_current_buf(buf)

  vim.keymap.set("n", "<C-x>", ":so<CR>", { buffer = buf, desc = "Sandbox: Run sandbox file as lua code" })
end, {})
