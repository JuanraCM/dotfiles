local utils = require("custom.utils")

vim.g.mapleader = " "
-- Leader inside a buffer
vim.g.maplocalleader = " "

-- Disables spacebar in normal and visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remaps to center cursor when moving/searching in file
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste without replacing current register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without replacing current register" })

-- Toggle relative numbers
vim.keymap.set("n", "<leader>tr", function()
  utils.notify_toggle("Relative numbers", function()
    vim.wo.relativenumber = not vim.wo.relativenumber
    return vim.wo.relativenumber
  end)
end, { desc = "Toggle relative numbers" })

-- Toggle line wrap
vim.keymap.set("n", "<leader>tw", function()
  utils.notify_toggle("Line wrap", function()
    vim.wo.wrap = not vim.wo.wrap
    return vim.wo.wrap
  end)
end, { desc = "Toggle line wrap" })

-- Toggle list characters
vim.keymap.set("n", "<leader>tc", function()
  utils.notify_toggle("List characters", function()
    vim.o.list = not vim.o.list
    return vim.o.list
  end)
end, { desc = "Toggle list characters" })

-- Yank relative file path to system clipboard
vim.keymap.set("n", "<leader>yf", ':let @+ = expand("%:.")<cr>', { desc = "Yank file path to clipboard" })

-- Substitute remaps
vim.keymap.set("v", '<leader>s"', ":s/\"/'/g<cr>", { desc = "Replace double quotes with single quotes" })
vim.keymap.set("v", "<leader>s'", ":s/'/\"/g<cr>", { desc = "Replace single quotes with double quotes" })

-- Remap for dealing with word wrap vertically
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap for exiting terminal mode
vim.keymap.set("t", "<c-q>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
