return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")

    conform.setup({
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
      formatters_by_ft = {
        lua = { "stylua" },
      },
      formatters = {
        rubocop = {
          command = require("custom.utils").script_path("docker-cmd"),
          args = function()
            return {
              vim.env.DOCKER_CONTAINER,
              "bundle",
              "exec",
              "rubocop",
              "-a",
              "-f",
              "quiet",
              "--stderr",
              "--stdin",
              vim.fn.expand("%:."),
            }
          end,
        },
      },
    })
  end,
}
