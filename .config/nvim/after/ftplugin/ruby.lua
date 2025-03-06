vim.api.nvim_buf_create_user_command(0, "RubocopFixAll", function(evt)
  local formatter = evt.bang and "rubocop_unsafe" or "rubocop"

  require("conform").format({
    formatters = { formatter },
    timeout_ms = 10000,
  })
end, { bang = true, desc = "Fix all rubocop offenses" })
