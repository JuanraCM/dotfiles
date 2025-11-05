---@module "snacks"

local M = {}

local ENV_FILE = ".nvim-env.json"
local ENV_VARS = {
  DOCKER_CONTAINER = "app",
  DISABLE_LSP_SERVERS = "",
}

M.load_env = function()
  local env_config = {}

  if vim.fn.filereadable(ENV_FILE) == 1 then
    local lines = vim.fn.readfile(ENV_FILE)
    local content = table.concat(lines, "\n")

    env_config = vim.json.decode(content)
  end

  for key, default_value in pairs(ENV_VARS) do
    vim.env[key] = env_config[key] or default_value
  end
end

M.script_path = function(fname)
  return table.concat({
    vim.fn.stdpath("config"),
    "scripts",
    fname,
  }, "/")
end

--- Toggles a feature and notifies the user about its status
---@param feature string
---@param toggle_fn fun(): boolean
M.notify_toggle = function(feature, toggle_fn)
  local toggle_fn_result = toggle_fn()
  local enabled = toggle_fn_result and "**enabled**" or "**disabled**"
  local formatted_message = string.format("%s: %s", feature, enabled)

  Snacks.notifier.notify(formatted_message)
end

return M
