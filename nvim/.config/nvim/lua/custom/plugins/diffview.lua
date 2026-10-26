return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>dh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History (current branch)" },
    { "<leader>dH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History (current file)" },
    { "<leader>dr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview Refresh" },
  },
}
