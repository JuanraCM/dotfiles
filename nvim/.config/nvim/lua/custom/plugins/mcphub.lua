return {
  "ravitemer/mcphub.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  build = "bundled_build.lua",
  config = function()
    require("mcphub").setup({})
  end,
}
