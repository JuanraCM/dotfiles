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

-- Markdown keymaps for pasting buffer/file paths
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownPathPasteKeymaps", { clear = true }),
  pattern = "markdown",
  callback = function(evt)
    local paste_file = function(picker)
      local selected = picker:selected({ fallback = true })
      local selected_count = #selected

      local fmt = selected_count > 1 and "- `%s`\n" or "`%s`"

      picker:close()

      for _, item in ipairs(selected) do
        vim.api.nvim_paste(fmt:format(item.file), true, -1)
      end
    end

    vim.keymap.set({ "n", "i" }, "<c-b>", function()
      Snacks.picker.buffers({
        confirm = function(picker)
          paste_file(picker)
        end,
      })
    end, { buffer = evt.buf, desc = "Paste buffer/s path" })

    vim.keymap.set({ "n", "i" }, "<c-f>", function()
      Snacks.picker.files({
        confirm = function(picker)
          paste_file(picker)
        end,
      })
    end, { buffer = evt.buf, desc = "Paste file/s path" })
  end,
})
