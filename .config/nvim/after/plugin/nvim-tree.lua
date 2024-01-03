local api = require "nvim-tree.api"

vim.keymap.set('n', '<C-b>', api.tree.toggle)

require("nvim-tree").setup {
  view = {
    width = 30,
  },

  filters = {
    dotfiles = false,
  }
}
