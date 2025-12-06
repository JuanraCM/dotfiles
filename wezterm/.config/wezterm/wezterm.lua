local wezterm = require("wezterm") ---@type Wezterm
local config = wezterm.config_builder() ---@type Config

-- Custom modules
local tab_bar_utils = require("tab-bar-utils")
local neovim_nav = require("neovim-nav")
local wsinit = wezterm.plugin.require("https://github.com/JuanraCM/wsinit.wezterm")

-- General settings
config.max_fps = 165

-- General appearance
config.color_scheme = "Catppuccin Mocha"
config.font_size = 13
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Tab bar settings
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 24
config.status_update_interval = 1000

---@type Palette
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local active_bg = scheme.tab_bar.active_tab.bg_color
local active_bg_alt = wezterm.color.parse(tostring(active_bg)):darken(0.2)
wezterm.on("update-status", function(window)
  local ram = tab_bar_utils.ram_usage()
  local ram_icon = wezterm.nerdfonts.cod_server

  local cpu = tab_bar_utils.cpu_usage()
  local cpu_icon = wezterm.nerdfonts.oct_cpu

  local ctime = wezterm.strftime("%Y-%m-%d %H:%M")
  local ctime_icon = wezterm.nerdfonts.fa_calendar

  window:set_right_status(wezterm.format({
    { Background = { Color = scheme.tab_bar.inactive_tab_hover.bg_color } },
    { Foreground = { Color = scheme.tab_bar.inactive_tab_hover.fg_color } },
    { Text = " " .. ram_icon .. "  " .. ram .. " | " .. cpu_icon .. "  " .. cpu .. " " },
    { Background = { Color = scheme.tab_bar.active_tab.bg_color } },
    { Foreground = { Color = scheme.tab_bar.active_tab.fg_color } },
    { Text = " " .. ctime_icon .. "  " .. ctime .. " " },
  }))

  window:set_left_status(wezterm.format({
    { Background = { Color = tostring(active_bg_alt) } },
    { Foreground = { Color = scheme.tab_bar.active_tab.fg_color } },
    { Text = " " .. wezterm.nerdfonts.cod_gear .. "  " .. window:active_workspace() .. " " },
  }))
end)

-- Keybindings
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  {
    key = "d",
    mods = "LEADER",
    action = wezterm.action.ShowDebugOverlay,
  },
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "q",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  {
    key = "Q",
    mods = "LEADER",
    action = wezterm.action.CloseCurrentTab({ confirm = true }),
  },
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
  },
  {
    key = ",",
    mods = "LEADER",
    action = wezterm.action.PromptInputLine({
      description = "Rename tab:",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  {
    key = "v",
    mods = "LEADER",
    action = wezterm.action.ActivateCopyMode,
  },
  {
    key = "%",
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = '"',
    mods = "LEADER|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = "h",
    mods = "CTRL",
    action = wezterm.action.EmitEvent("MovePaneLeft"),
  },
  {
    key = "j",
    mods = "CTRL",
    action = wezterm.action.EmitEvent("MovePaneDown"),
  },
  {
    key = "k",
    mods = "CTRL",
    action = wezterm.action.EmitEvent("MovePaneUp"),
  },
  {
    key = "l",
    mods = "CTRL",
    action = wezterm.action.EmitEvent("MovePaneRight"),
  },
  { key = "H", mods = "CTRL", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
  {
    key = "J",
    mods = "CTRL",
    action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
  },
  {
    key = "K",
    mods = "CTRL",
    action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
  },
  {
    key = "L",
    mods = "CTRL",
    action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action.RotatePanes("Clockwise"),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action.RotatePanes("CounterClockwise"),
  },
}
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i - 1),
  })

  table.insert(config.keys, {
    key = tostring(i),
    mods = "CTRL",
    action = wezterm.action.MoveTab(i - 1),
  })
end

-- Neovim pane navigation setup
neovim_nav.setup({
  MovePaneLeft = { direction = "Left", key = "h" },
  MovePaneRight = { direction = "Right", key = "l" },
  MovePaneDown = { direction = "Down", key = "j" },
  MovePaneUp = { direction = "Up", key = "k" },
})

wsinit.setup({
  workspaces_dir = wezterm.home_dir .. "/.workspaces",
})
wsinit.apply_to_config(config)

-- MacOS stuff
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

return config
