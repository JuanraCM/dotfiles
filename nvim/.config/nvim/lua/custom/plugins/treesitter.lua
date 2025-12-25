return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "master",
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
      indent = {
        enable = true,
        disable = { "ruby" },
      },
      modules = {},
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select the outer part of a function" },
            ["if"] = { query = "@function.inner", desc = "Select the inner part of a function" },
            ["ac"] = { query = "@class.outer", desc = "Select the outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "Select the inner part of a class" },
            ["ab"] = { query = "@block.outer", desc = "Select the outer part of a block" },
            ["ib"] = { query = "@block.inner", desc = "Select the inner part of a block" },
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
