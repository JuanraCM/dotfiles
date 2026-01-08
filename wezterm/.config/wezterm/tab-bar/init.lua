local M = {}

---@type Wezterm
local wezterm = require("wezterm")
local utils = require("tab-bar.utils")

local tbl_insert = function(tbl, ...)
  for _, v in ipairs({ ... }) do
    table.insert(tbl, v)
  end
end

M.setup = function(config)
  ---@type Palette
  local color_scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
  local nf = wezterm.nerdfonts

  wezterm.on("update-status", function(window)
    local ctime = wezterm.strftime("%Y-%m-%d %H:%M")
    local ram = utils.ram_usage()
    local cpu = utils.cpu_usage()

    local left_status = {}
    local right_status = {}

    tbl_insert(
      left_status,
      { Background = { Color = color_scheme.tab_bar.inactive_tab_hover.bg_color } },
      { Foreground = { Color = color_scheme.tab_bar.inactive_tab_hover.fg_color } },
      { Text = " " .. nf.cod_layout .. "  " .. window:active_workspace() .. " " }
    )

    if ram and cpu then
      tbl_insert(
        right_status,
        { Background = { Color = color_scheme.tab_bar.inactive_tab_hover.bg_color } },
        { Foreground = { Color = color_scheme.tab_bar.inactive_tab_hover.fg_color } },
        { Text = " " .. nf.cod_server .. "  " .. ram .. " | " .. nf.oct_cpu .. "  " .. cpu .. " " }
      )
    end

    tbl_insert(
      right_status,
      { Background = { Color = color_scheme.tab_bar.active_tab.bg_color } },
      { Foreground = { Color = color_scheme.tab_bar.active_tab.fg_color } },
      { Text = " " .. nf.fa_calendar .. "  " .. ctime .. " " }
    )

    window:set_left_status(wezterm.format(left_status))
    window:set_right_status(wezterm.format(right_status))
  end)
end

return M
