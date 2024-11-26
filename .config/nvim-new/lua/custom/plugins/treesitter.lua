return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function ()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = { "lua", "ruby" },
      ignore_install = {},
      sync_install = false,
      auto_install = true,
      modules = {}
    })
  end
}
