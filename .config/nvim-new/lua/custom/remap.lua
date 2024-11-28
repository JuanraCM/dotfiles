
vim.g.mapleader = ' '
-- Leader inside a buffer
vim.g.maplocalleader = ' '

-- Disables spacebar in normal and visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remaps to center cursor when moving/searching in file
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Paste without replacing current register
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without replacing current register' })

-- Buffer navigation
vim.keymap.set('n', 'bn', ':bnext<enter>', { desc = 'Go to next buffer' })
vim.keymap.set('n', 'bp', ':bprevious<enter>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', 'bd', ':bdelete<enter>', { desc = 'Delete current buffer' })
