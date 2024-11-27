return {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  -- This module is required to allow asynchronous programming using coroutines
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function ()
    local builtin = require('telescope.builtin')

    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>sa', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
  end
}
