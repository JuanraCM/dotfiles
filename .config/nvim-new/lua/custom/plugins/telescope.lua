return {
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    -- This module is required to allow asynchronous programming using coroutines
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function ()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      telescope.setup({
        defaults = {
          file_ignore_patterns = { '.git', '.node_modules' },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden'
          }
        },
      })

      pcall(telescope.load_extension, 'fzf')

      vim.keymap.set('n', '<leader>sf', function ()
        builtin.find_files({ hidden = true })
      end, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>sa', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Telescope grep word under cursor' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>sg', builtin.git_files, { desc = 'Telescope find git files' })
      vim.keymap.set('n', '<leader>sc', builtin.git_bcommits, { desc = "Telescope find buffer's git commits" })
      vim.keymap.set('n', '<leader>sC', builtin.git_commits, { desc = "Telescope find git commits" })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope find help tags' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Telescope find keymaps' })
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzily search in current buffer' })
    end
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
}
