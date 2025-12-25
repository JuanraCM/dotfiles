---@module "snacks"

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    {
      "folke/lazydev.nvim",
      dependencies = {
        "DrKJeff16/wezterm-types",
        lazy = true,
        version = false,
      },
      ft = "lua",
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
          -- Load the wezterm types when the `wezterm` module is required
          { path = "wezterm-types", mods = { "wezterm" } },
        },
      },
    },
  },
  config = function()
    require("mason").setup()
    require("lazydev").setup()

    local servers = {
      lua_ls = {},
      ruby_lsp = {},
      solargraph = {},
      rust_analyzer = {},
      eslint = {},
      ts_ls = {},
      pyright = {},
      ruff = {},
      emmet_language_server = {},
      clangd = {},
      jsonls = {},
      bashls = {},
      nil_ls = {},
    }

    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local on_attach = function(_, bufnr)
      ---@module "snacks"

      vim.keymap.set(
        "n",
        "<leader>gd",
        Snacks.picker.lsp_definitions,
        { buffer = bufnr, desc = "[LSP] Go to definition" }
      )
      vim.keymap.set(
        "n",
        "<leader>fr",
        Snacks.picker.lsp_references,
        { buffer = bufnr, desc = "[LSP] Find references" }
      )
      vim.keymap.set("n", "<leader>fs", Snacks.picker.lsp_symbols, { buffer = bufnr, desc = "[LSP] Find symbols" })
      vim.keymap.set(
        "n",
        "<leader>fS",
        Snacks.picker.lsp_workspace_symbols,
        { buffer = bufnr, desc = "[LSP] Find workspace symbols" }
      )
    end

    local disabled_servers = vim.split(vim.env.DISABLE_LSP_SERVERS or "", ",", { trimempty = true })
    for _, server in pairs(disabled_servers) do
      servers[server] = nil
    end

    for server, config in pairs(servers) do
      local server_setup = vim.tbl_extend("keep", config, {
        capabilities = capabilities,
        on_attach = on_attach,
      })

      vim.lsp.config(server, server_setup)
      vim.lsp.enable(server)
    end

    vim.api.nvim_create_autocmd("LspProgress", {
      group = vim.api.nvim_create_augroup("SnacksLspProgress", { clear = true }),
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if not client or client.name == "solargraph" then
          return
        end

        local notif_id = "lsp_progress_" .. client.id
        Snacks.notifier.notify(vim.lsp.status(), "info", {
          id = notif_id,
          title = client.name,
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == "end" and " " or Snacks.util.spinner()
          end,
        })
      end,
    })
  end,
}
