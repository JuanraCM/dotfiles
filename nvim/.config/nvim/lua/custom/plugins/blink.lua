return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local custom_vars = {
      lazy = {
        BDD_TASK_ID = function()
          local branch_name = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait().stdout
          return branch_name and vim.split(branch_name, "-")[2] or "UNKNOWN"
        end,
      },
      eager = {},
    }

    local registry = require("blink.cmp.sources.snippets.default.registry")
    local aggregated_vars = vim.tbl_deep_extend("force", registry.builtin_vars, custom_vars)
    registry.builtin_vars = aggregated_vars

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
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
          mysql = { "snippets", "dadbod", "buffer" },
          codecompanion = { "codecompanion" },
        },
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
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
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
