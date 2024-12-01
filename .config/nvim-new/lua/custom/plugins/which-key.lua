return {
  "folke/which-key.nvim",
  opts = {},
  config = function ()
    vim.keymap.set('n', '<leader>?', function ()
      require('which-key').show({ global = false })
    end, { desc = "Buffer local keymaps" })
  end
}
