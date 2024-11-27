
vim.g.mapleader = ' '
-- Leader inside a buffer
vim.g.maplocalleader = ' '

-- Remaps to center cursor when moving/searching in file
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Paste without replacing current register
vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste without replacing current register' })
