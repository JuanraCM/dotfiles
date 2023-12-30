local diffview_is_open = false

vim.keymap.set('n', '<C-g>', function()
  if diffview_is_open then
    vim.cmd.DiffviewClose()
  else
    vim.cmd.DiffviewOpen()
  end

  diffview_is_open = not diffview_is_open
end)

require("diffview").setup {
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = false,
    },

    merge_tool = {
      layout = "diff1_plain",
      disable_diagnostics = true,
      winbar_info = false,
    }
  }
}
