---@module "snacks"

local CONFIG_PATH = vim.fn.stdpath("data") .. "/../login_tol/accounts.json"

local function read_json_items(path)
  local content = vim.fn.readfile(path)

  return vim.fn.json_decode(content)
end

vim.api.nvim_create_user_command("LoginTOLConfig", function()
  vim.cmd("edit " .. CONFIG_PATH)
end, { desc = "Login TOL Config" })

vim.api.nvim_create_user_command("LoginTOL", function()
  local items = read_json_items(CONFIG_PATH)
  local curl = require("plenary.curl")

  Snacks.picker({
    title = "Login TOL",
    layout = { preset = "select" },
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      Snacks.notify("Logging into " .. item.text .. "...")

      local response = curl.get({ url = item.url })

      picker:close()
      vim.ui.open(response.body)
    end,
  })
end, { desc = "Login TOL" })
