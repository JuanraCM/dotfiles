---@module "snacks"

return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  config = function()
    local highlights = require("rose-pine.plugins.bufferline")

    require("bufferline").setup({
      highlights = highlights,
      options = {
        close_command = function(n)
          Snacks.bufdelete(n)
        end,
        show_buffer_close_icons = false,
      },
    })
  end,
  keys = {
    {
      "<S-h>",
      function()
        require("bufferline").cycle(-1)
      end,
      desc = "Previous Buffer",
    },
    {
      "<S-l>",
      function()
        require("bufferline").cycle(1)
      end,
      desc = "Next Buffer",
    },
    {
      "<leader>bl",
      function()
        require("bufferline").close_in_direction("left")
      end,
      desc = "Delete Buffers to the Left",
    },
    {
      "<leader>br",
      function()
        require("bufferline").close_in_direction("right")
      end,
      desc = "Delete Buffers to the Right",
    },
    {
      "<leader>bo",
      function()
        require("bufferline").close_others()
      end,
      desc = "Delete Other Buffers",
    },
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Current Buffer",
    },
  },
}
