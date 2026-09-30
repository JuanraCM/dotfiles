return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp",
  },
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept_word = "<C-l>",
          accept_line = "<C-j>",
        },
      },
    })
  end,
}
