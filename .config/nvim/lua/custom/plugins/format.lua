return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")

    conform.setup({
      format_on_save = {
        lsp_format = "never",
        timeout_ms = 500,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        ruby = { "rubyfmt" },
      },
    })
  end,
}
