-- Remaps for executing code when editing Lua files
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ExecLuaCodeKeymaps", { clear = true }),
  pattern = "lua",
  callback = function(evt)
    vim.keymap.set("n", "<leader>x", ":so<CR>", { buffer = evt.buf, desc = "Run code" })
    vim.keymap.set("v", "<leader>x", ":lua<CR>", { buffer = evt.buf, desc = "Run selected code" })
  end,
})

-- Hightlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true }),
  callback = function(_)
    vim.highlight.on_yank()
  end,
})
