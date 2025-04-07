return {
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<c-g>", ":vertical G<cr>", { desc = "Open git status in a vertical buffer" })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
          vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
          vim.keymap.set("n", "<leader>hv", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
          vim.keymap.set(
            "n",
            "<leader>hi",
            gitsigns.preview_hunk_inline,
            { buffer = bufnr, desc = "Preview hunk inline" }
          )
          vim.keymap.set("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { buffer = bufnr, desc = "Stage hunk" })
          vim.keymap.set("v", "<leader>hr", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { buffer = bufnr, desc = "Reset hunk" })

          vim.keymap.set("n", "<leader>hn", function()
            gitsigns.nav_hunk("next")
          end, { buffer = bufnr, desc = "Navigate to next hunk" })
          vim.keymap.set("n", "<leader>hp", function()
            gitsigns.nav_hunk("prev")
          end, { buffer = bufnr, desc = "Navigate to previous hunk" })

          vim.keymap.set(
            "n",
            "<leader>tb",
            gitsigns.toggle_current_line_blame,
            { buffer = bufnr, desc = "Toggle current line blame" }
          )
        end,
      })
    end,
  },
}
