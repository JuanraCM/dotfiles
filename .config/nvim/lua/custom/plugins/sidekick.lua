return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      context = {
        clipboard = function(_)
          return vim.fn.getreg("+")
        end,
      },
      prompts = {
        mr_review = "Would you analyze the following Merge Request and search for possible issues, improvements, and suggestions?\n{clipboard}",
      },
    },
  },
  keys = {
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle()
      end,
      mode = { "n", "v" },
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").send({ selection = true })
      end,
      mode = { "v" },
      desc = "Sidekick Send Visual Selection",
    },
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      mode = { "n" },
      desc = "Sidekick Send File",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "v" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<c-.>",
      function()
        require("sidekick.cli").focus()
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
    {
      "<leader>ac",
      function()
        require("sidekick.cli").toggle({ name = "copilot", focus = true })
      end,
      desc = "Sidekick Copilot Toggle",
      mode = { "n", "v" },
    },
    {
      "<leader>ag",
      function()
        require("sidekick.cli").toggle({ name = "gemini", focus = true })
      end,
      desc = "Sidekick Gemini Toggle",
      mode = { "n", "v" },
    },
    {
      "<leader>tn",
      function()
        require("custom.utils").notify_toggle("Sidekick NES", require("sidekick.nes").toggle)
      end,
      desc = "Toggle Sidekick NES",
      mode = { "n" },
    },
  },
}
