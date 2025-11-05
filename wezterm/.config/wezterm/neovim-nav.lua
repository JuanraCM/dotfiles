local M = {}

local wezterm = require("wezterm") ---@type Wezterm
local action = wezterm.action

local is_nvim = function(pane)
  local process_name = pane:get_foreground_process_name()

  return process_name:find("nvim") ~= nil
end

local move_to = function(window, pane, evt_cfg)
  if is_nvim(pane) then
    window:perform_action(action.SendKey({ key = evt_cfg.key, mods = "CTRL" }), pane)
  else
    window:perform_action(action.ActivatePaneDirection(evt_cfg.direction), pane)
  end
end

M.setup = function(events)
  for evt, cfg in pairs(events) do
    wezterm.on(evt, function(window, pane)
      move_to(window, pane, cfg)
    end)
  end
end

return M
