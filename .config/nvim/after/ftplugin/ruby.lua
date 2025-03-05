vim.api.nvim_buf_create_user_command(0, "RubocopFixAll", function()
  require("conform").format({
    formatters = { "rubocop" },
    timeout_ms = 5000,
  })
end, { desc = "Fix all rubocop offenses" })
