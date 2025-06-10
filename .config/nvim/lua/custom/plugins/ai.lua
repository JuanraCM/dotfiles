return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "github/copilot.vim",
    {
      "ravitemer/mcphub.nvim",
      build = "npm install -g mcp-hub@latest",
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  config = function()
    require("mcphub").setup()
    require("codecompanion").setup({
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true,
            make_vars = true,
            make_slash_commands = true,
          },
        },
      },
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            schema = {
              model = {
                default = "gemini-2.5-pro-preview-05-06",
              },
            },
          })
        end,
      },
    })
    require("custom.codecompanion-progress"):init()
  end,
  keys = {
    { "<c-t>", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanionChat" },
    { "<c-t>", ":CodeCompanionChat Add<cr>", mode = "v", desc = "Open CodeCompanionChat with selected code" },
    { "tm", ":RenderMarkdown buf_toggle<cr>", desc = "Toggle RenderMarkdown" },
  },
}
