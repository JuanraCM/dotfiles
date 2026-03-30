return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
  build = ":TSUpdate",
  config = function()
    local query = require("vim.treesitter.query")

    require("nvim-treesitter").setup({
      ensure_installed = { "lua", "ruby" },
      ignore_install = {},
      sync_install = false,
      auto_install = true,
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "*" },
      callback = function(ev)
        _, error = vim.treesitter.get_parser(ev.buf)

        if not error then
          vim.treesitter.start(ev.buf)
        end
      end,
    })

    query.add_directive("set-lang-from-filename!", function(_, _, bufnr, _, metadata)
      local filename = vim.api.nvim_buf_get_name(bufnr):match("([^/]+)%.lua$")

      metadata["injection.language"] = filename
    end, { force = true, all = false })
  end,
}
