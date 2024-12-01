return {
  {
    "catppuccin/nvim",
    enabled = false,
    name = "catppuccin",
    priority = 1000,
    config = function ()
      vim.cmd.colorscheme "catppuccin-macchiato"
    end
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function ()
      vim.cmd.colorscheme "rose-pine-moon"
    end
  }
}
