return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  version = 'v0.*',
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      providers = {
        snippets = {
          opts = {
            search_paths = { vim.fn.stdpath('config') .. '/lua/custom/snippets' }
          }
        }
      }
    },
    signature = { enabled = true },
    completion = {
      menu = {
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", "source_name", gap = 1 },
          }
        }
      },
      documentation = { auto_show = true }
    },
  },
  opts_extend = { "sources.default" }
}
