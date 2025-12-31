return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      win = {
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
      "<c-s>",
      function()
        require("sidekick.cli").focus("opencode")
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
    {
      "<c-s>",
      function()
        require("sidekick.cli").send({ name = "opencode", selection = true })
      end,
      mode = { "v" },
      desc = "Sidekick Send Visual Selection",
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
