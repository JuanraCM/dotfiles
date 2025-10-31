return {
  label = "Test",
  setup = function(mux_window, home_dir)
    mux_window:spawn_tab({ cwd = home_dir })

    mux_window:active_tab():set_title("Test")
    mux_window:active_pane():send_text("echo 'This is a test workspace'\n")
  end,
}
