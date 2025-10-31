return {
  label = "Tirant",
  setup = function(mux_window, home_dir)
    mux_window:active_tab():set_title("Main")

    local tabs_config = {
      {
        cwd = home_dir .. "/Tirant/tol_dependencies",
        name = "dependencies",
      },
      {
        cwd = home_dir .. "/Tirant/toluserapi/api",
        name = "toluserapi",
      },
      {
        cwd = home_dir .. "/Tirant/api/apitol",
        name = "apitol",
      },
      {
        cwd = home_dir .. "/Tirant/tolweb",
        name = "tolweb",
      },
      {
        cwd = home_dir .. "/Tirant/tirantonline",
        name = "tirantonline",
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
