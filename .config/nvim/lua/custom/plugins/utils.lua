---@module "snacks"

return {
  "folke/snacks.nvim",
  opts = {
    gitbrowse = {},
    indent = {},
  },
  keys = {
    {
      "<leader>gr",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Open remote repository",
    },
  },
}
