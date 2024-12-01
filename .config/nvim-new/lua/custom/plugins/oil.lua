return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  config = function ()
    require('oil').setup({
      view_options = {
        show_hidden = true
      }
    })

    vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = "Open parent directory" })
  end
}
