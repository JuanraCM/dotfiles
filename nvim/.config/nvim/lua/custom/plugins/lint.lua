return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")
    local cutils = require("custom.utils")

    lint.linters_by_ft = {
      ruby = { "rubocop" },
    }

    local rubocop_args = {
      "exec",
      "rubocop",
      "--format",
      "json",
      "--force-exclusion",
      "--stdin",
      function()
        return vim.fn.expand("%:.")
      end,
    }

    if vim.env.DOCKER_CONTAINER then
      lint.linters.rubocop.cmd = cutils.script_path("docker-cmd")
      table.insert(rubocop_args, 1, vim.env.DOCKER_CONTAINER)
      table.insert(rubocop_args, 2, "bundle")
    else
      lint.linters.rubocop.cmd = "bundle"
    end

    lint.linters.rubocop.args = rubocop_args

    local lint_enabled = true

    vim.keymap.set("n", "<leader>tl", function()
      lint_enabled = not lint_enabled

      cutils.notify_toggle("Linters", function()
        return lint_enabled
      end)

      if not lint_enabled then
        vim.diagnostic.reset(nil, 0)
      end
    end, { desc = "Toggle linters" })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
      callback = function()
        if lint_enabled then
          lint.try_lint()
        end
      end,
    })
  end,
}
