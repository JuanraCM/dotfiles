return {
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup()

      vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
      vim.keymap.set("n", "<c-g>", ":vertical G<cr>", { desc = "Open git status in a vertical buffer" })
    end,
  },
}
