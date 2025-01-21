return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/lua/custom/snippets" })

    local ls = require("luasnip")
    local types = require("luasnip.util.types")

    ls.setup({
      update_events = { "TextChanged", "TextChangedI" },
      ext_opts = {
        [types.choiceNode] = {
          active = {
            hl_group = "DiffAdd",
          },
        },
      },
    })

    vim.keymap.set("i", "<C-n>", "<Plug>luasnip-next-choice", {})
    vim.keymap.set("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
    vim.keymap.set("i", "<C-s>", require("luasnip.extras.select_choice"), {})
  end,
}
