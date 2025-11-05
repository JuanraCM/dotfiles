return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")

    local rubocop_args = function(safe_mode)
      return function()
        return {
          vim.env.DOCKER_CONTAINER,
          "bundle",
          "exec",
          "rubocop",
          safe_mode and "-a" or "-A",
          "-f",
          "quiet",
          "--stderr",
          "--stdin",
          vim.fn.expand("%:."),
        }
      end
    end

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
          args = rubocop_args(true),
        },
        rubocop_unsafe = {
          command = require("custom.utils").script_path("docker-cmd"),
          args = rubocop_args(false),
          exit_codes = { 0, 1 },
        },
      },
    })
  end,
}
