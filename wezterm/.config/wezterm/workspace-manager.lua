local M = {
  workspaces = {},
}

local wezterm = require("wezterm") ---@type Wezterm

M.load_workspaces = function()
  for _, v in ipairs(wezterm.glob(wezterm.config_dir .. "/workspaces/*.lua")) do
    local workspace_name = v:match("workspaces/(.+)%.lua$")
    if workspace_name then
      local workspace_module = require("workspaces." .. workspace_name)
      M.workspaces[workspace_name] = workspace_module
    end
  end
end

M.list = function()
  local labels = {}

  for wid, workspace in pairs(M.workspaces) do
    table.insert(labels, { id = wid, label = workspace.label })
  end

  return labels
end

M.setup_workspace = function(wid, window)
  local workspace = M.workspaces[wid]

  if workspace then
    local mux_window = wezterm.mux.get_window(window:window_id())
    workspace.setup(mux_window, wezterm.home_dir)
  end
end

return M
