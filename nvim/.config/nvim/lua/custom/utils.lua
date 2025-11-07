---@module "snacks"

local M = {}

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
