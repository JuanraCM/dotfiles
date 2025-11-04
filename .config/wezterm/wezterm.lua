local wezterm = require("wezterm") ---@type Wezterm
local config = wezterm.config_builder() ---@type Config

-- Custom modules
local neovim_nav = require("neovim-nav")
local workspace_mng = require("workspace-manager")
workspace_mng.load_workspaces()

-- General settings
config.max_fps = 165

-- Appearance
config.color_scheme = "Catppuccin Mocha"
config.font_size = 13
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false

-- Keybindings
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
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
    key = "w",
    mods = "LEADER",
    action = wezterm.action.InputSelector({
      title = "Select workspace",
      choices = workspace_mng.list(),
      action = wezterm.action_callback(function(window, _, wid)
        if wid then
          workspace_mng.setup_workspace(wid, window)
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
    mods = "LEADER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = '"',
    mods = "LEADER",
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

-- MacOS stuff
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

return config
