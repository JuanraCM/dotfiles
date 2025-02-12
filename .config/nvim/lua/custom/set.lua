-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set tab config to 2 spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2

-- Built-in smartindent
vim.opt.smartindent = true

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Use relative numbers by default
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = "unnamedplus"

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Leave lines of margin when scrolling
vim.opt.scrolloff = 8

-- Split to right
vim.o.splitright = true

-- Prettier fold text
function _G.custom_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1

  return line .. "..." .. ": " .. line_count .. " lines"
end

vim.opt.foldtext = "v:lua.custom_foldtext()"

-- Custom fillchars
vim.opt.fillchars = { fold = " " }

-- Cursor style
vim.api.nvim_set_hl(0, "CustomCursor", { bg = "#a8a6b1" })
vim.o.guicursor = "n-v-c-sm:block-CustomCursor,i-ci-ve:ver25,r-cr-o:hor20"
