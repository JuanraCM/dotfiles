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

-- Buffer navigation
vim.keymap.set("n", "gb", ":bnext<cr>", { desc = "Go to next buffer" })
vim.keymap.set("n", "gp", ":bprevious<cr>", { desc = "Go to previous buffer" })

-- Toggle relative numbers
vim.keymap.set("n", "<leader>tr", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative numbers" })

-- Toggle line wrap
vim.keymap.set("n", "<leader>tw", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle line wrap" })

-- Yank relative file path to system clipboard
vim.keymap.set("n", "<leader>yf", ':let @+ = expand("%")<cr>', { desc = "Yank file path to clipboard" })
