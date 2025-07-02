---@module "snacks"

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
    vim.keymap.set("i", "<c-l>", "<Plug>(copilot-accept-word)")
    vim.keymap.set("i", "<c-j>", 'copilot#Accept("<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.g.copilot_no_tab_map = true

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

    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequestStarted",
      group = vim.api.nvim_create_augroup("SnacksCodeCompanionProgress", { clear = true }),
      callback = function(request)
        local notif_title = "CodeCompanion (" .. request.data.strategy .. ")"
        local notif_msg = "**" .. request.data.adapter.model .. "** Requesting assistance..."
        Snacks.notifier.notify(notif_msg, "info", {
          opts = function(notif)
            notif.title = notif_title
            notif.icon = Snacks.util.spinner()
          end,
        })
      end,
    })
  end,
  keys = {
    { "<c-t>", ":CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanionChat" },
    { "<c-t>", ":CodeCompanionChat Add<cr>", mode = "v", desc = "Open CodeCompanionChat with selected code" },
    { "tm", ":RenderMarkdown buf_toggle<cr>", desc = "Toggle RenderMarkdown" },
  },
}
