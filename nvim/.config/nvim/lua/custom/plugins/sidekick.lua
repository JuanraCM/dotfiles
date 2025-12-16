return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        bo = { buflisted = true },
        split = { width = 0 },
      },
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
      "<leader>ao",
      function()
        require("sidekick.cli").toggle({ name = "opencode", focus = true })
      end,
      desc = "Sidekick Opencode Toggle",
      mode = { "n", "v" },
    },
    {
      "<leader>tn",
      function()
        local nes_toggle_wrapper = function()
          require("sidekick.nes").toggle()

          return require("sidekick.nes").enabled
        end

        require("custom.utils").notify_toggle("Sidekick NES", nes_toggle_wrapper)
      end,
      desc = "Toggle Sidekick NES",
      mode = { "n" },
    },
  },
}
