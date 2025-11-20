---@module "snacks"

-- Yanks the content of a specified register to the system clipboard.
vim.api.nvim_create_user_command("YankRegister", function(opts)
  local register = opts.args
  local content = vim.fn.getreg(register)

  vim.fn.setreg("+", content)
  print("Yanked value '" .. content .. "' to clipboard.")
end, { nargs = 1 })
