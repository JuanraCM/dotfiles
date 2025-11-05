return {
  label = "Learning",
  setup = function(mux_window, home_dir)
    mux_window:active_tab():set_title("Main")

    local tabs_config = {
      {
        cwd = home_dir .. "/Learning/c-programming-guide",
        name = "learning-c",
      },
    }

    for _, tab_config in pairs(tabs_config) do
      mux_window:spawn_tab({ cwd = tab_config.cwd })
      mux_window:active_tab():set_title(tab_config.name)

      mux_window:active_pane():send_text("nvim\n")
      mux_window:active_pane():split({ direction = "Right" })
    end
  end,
}
