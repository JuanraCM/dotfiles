local M = {}

---@type Wezterm
local wezterm = require("wezterm")
local utils = require("tab-bar.utils")

M.setup = function(config)
  ---@type Palette
  local color_scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

  wezterm.on("update-status", function(window)
    local ram = utils.ram_usage()
    local ram_icon = wezterm.nerdfonts.cod_server

    local cpu = utils.cpu_usage()
    local cpu_icon = wezterm.nerdfonts.oct_cpu

    local ctime = wezterm.strftime("%Y-%m-%d %H:%M")
    local ctime_icon = wezterm.nerdfonts.fa_calendar

    window:set_right_status(wezterm.format({
      { Background = { Color = color_scheme.tab_bar.inactive_tab_hover.bg_color } },
      { Foreground = { Color = color_scheme.tab_bar.inactive_tab_hover.fg_color } },
      { Text = " " .. ram_icon .. "  " .. ram .. " | " .. cpu_icon .. "  " .. cpu .. " " },
      { Background = { Color = color_scheme.tab_bar.active_tab.bg_color } },
      { Foreground = { Color = color_scheme.tab_bar.active_tab.fg_color } },
      { Text = " " .. ctime_icon .. "  " .. ctime .. " " },
    }))

    window:set_left_status(wezterm.format({
      { Background = { Color = color_scheme.tab_bar.inactive_tab_hover.bg_color } },
      { Foreground = { Color = color_scheme.tab_bar.inactive_tab_hover.fg_color } },
      { Text = " " .. wezterm.nerdfonts.cod_layout .. "  " .. window:active_workspace() .. " " },
    }))
  end)
end

return M
