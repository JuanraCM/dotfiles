return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              model = "gemini-2.5-pro-exp-03-25",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
      },
    })

    vim.keymap.set("n", "<c-c>", ":CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanionChat" })
    vim.keymap.set("v", "<c-c>", ":CodeCompanionChat Add<cr>", { desc = "Open CodeCompanionChat with selected code" })

    vim.keymap.set("n", "tm", ":RenderMarkdown buf_toggle<cr>", { desc = "Toggle RenderMarkdown" })
  end,
}
