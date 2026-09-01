return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
  build = ":TSUpdate",
  config = function()
    -- Start treesitter if available
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { '*' },
      callback = function(ev)
        local _, error = vim.treesitter.get_parser(ev.buf)

        if not error then
          vim.treesitter.start(ev.buf)
        end
      end,
    })

    -- Textobject keymaps
    vim.keymap.set({ "x", "o" }, "af", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ab", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@block.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ib", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@block.inner", "textobjects")
    end)
  end,
}
