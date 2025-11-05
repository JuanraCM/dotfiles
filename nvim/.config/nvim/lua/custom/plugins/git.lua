return {
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      local utils = require("custom.utils")

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

          vim.keymap.set("n", "<c-n>", function()
            gitsigns.nav_hunk("next")
          end, { buffer = bufnr, desc = "Navigate to next hunk" })
          vim.keymap.set("n", "<c-p>", function()
            gitsigns.nav_hunk("prev")
          end, { buffer = bufnr, desc = "Navigate to previous hunk" })

          vim.keymap.set("n", "<leader>tb", function()
            utils.notify_toggle("Current line blame", gitsigns.toggle_current_line_blame)
          end, { buffer = bufnr, desc = "Toggle current line blame" })
        end,
      })
    end,
    event = "BufReadPre",
  },
}
