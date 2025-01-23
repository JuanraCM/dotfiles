return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    local query = require("vim.treesitter.query")

    configs.setup({
      ensure_installed = { "lua", "ruby" },
      ignore_install = {},
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      modules = {},
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select the outer part of a function" },
            ["if"] = { query = "@function.inner", desc = "Select the inner part of a function" },
          },
        },
      },
    })

    query.add_directive("set-lang-from-filename!", function(_, _, bufnr, _, metadata)
      local filename = vim.api.nvim_buf_get_name(bufnr):match("([^/]+)%.lua$")

      metadata["injection.language"] = filename
    end, { force = true, all = false })
  end,
}
