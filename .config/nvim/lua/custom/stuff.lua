-- Deletes buffer
vim.api.nvim_create_user_command("Q", function (evt)
  vim.cmd({ cmd = "bdelete", bang = evt.bang })
end, { bang = true })

-- Creates a temporary sandbox buffer that executes Lua code
vim.api.nvim_create_user_command("Sandbox", function (_)
  local buf = vim.api.nvim_create_buf(true, false)

  vim.api.nvim_buf_set_name(buf, "Sandbox")
  vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_current_buf(buf)

  vim.keymap.set("n", "<leader>x", ":so<CR>", { buffer = buf, desc = "Sandbox: Run code" })
  vim.keymap.set("v", "<leader>x", ":lua<CR>", { buffer = buf, desc = "Sandbox: Run selected code" })
end, {})
