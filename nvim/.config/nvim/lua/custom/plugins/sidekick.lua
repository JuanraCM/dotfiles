return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        split = { width = 0 },
        keys = {
          hide_ctrl_a = { "<c-a>", "hide", mode = "nt", desc = "hide the terminal window" },
        },
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
      "<c-a>",
      function()
        require("sidekick.cli").focus("opencode")
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
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
