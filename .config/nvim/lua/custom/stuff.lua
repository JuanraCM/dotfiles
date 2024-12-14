-- Deletes buffer
vim.api.nvim_create_user_command("Q", function (evt)
  vim.cmd({ cmd = "bdelete", bang = evt.bang })
end, { bang = true })

-- Remaps for executing code when editing Lua files
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ExecLuaCodeKeymaps", { clear = true }),
  pattern = "lua",
  callback = function (evt)
    vim.keymap.set("n", "<leader>x", ":so<CR>", { buffer = evt.buf, desc = "Run code" })
    vim.keymap.set("v", "<leader>x", ":lua<CR>", { buffer = evt.buf, desc = "Run selected code" })
  end
})

-- Creates a temporary sandbox buffer for a given language
vim.api.nvim_create_user_command("Sandbox", function (evt)
  local type = evt.fargs[1]
  local buf = vim.api.nvim_create_buf(true, false)

  vim.api.nvim_buf_set_name(buf, "Sandbox" .. " (" .. type .. ")")
  vim.api.nvim_set_option_value("filetype", type, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_current_buf(buf)
end, { nargs = 1 })

