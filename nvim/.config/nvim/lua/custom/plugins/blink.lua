return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    require("blink.cmp").setup({
      fuzzy = { implementation = "rust" },
      keymap = {
        preset = "default",
        ["<C-Space>"] = false,
        ["<C-s>"] = { "show" }
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lsp = { async = true },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          snippets = {
            score_offset = -2,
            opts = {
              search_paths = { vim.fn.stdpath("config") .. "/lua/custom/snippets" },
            },
          },
        },
      },
      signature = { enabled = true },
      completion = {
        menu = {
          draw = {
            columns = {
              { "label",     "label_description", gap = 1 },
              { "kind_icon", "kind",              "source_name", gap = 1 },
            },
          },
        },
        documentation = { auto_show = true },
      },
    })
  end,
}
