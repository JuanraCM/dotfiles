return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
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
    }

    local capabilities = require("blink.cmp").get_lsp_capabilities()
    local on_attach = function(_, bufnr)
      local builtin = require("telescope.builtin")

      vim.keymap.set(
        "n",
        "<leader>gd",
        builtin.lsp_definitions,
        { buffer = bufnr, desc = "[LSP] Telescope go to definition" }
      )
      vim.keymap.set(
        "n",
        "<leader>fs",
        builtin.lsp_document_symbols,
        { buffer = bufnr, desc = "[LSP] Telescope search document symbols" }
      )
      vim.keymap.set(
        "n",
        "<leader>fS",
        builtin.lsp_workspace_symbols,
        { buffer = bufnr, desc = "[LSP] Telescope search workspace symbols" }
      )
      vim.keymap.set(
        "n",
        "<leader>fr",
        builtin.lsp_references,
        { buffer = bufnr, desc = "[LSP] Telescope search references word under cursor" }
      )
    end

    local lspconfig = require("lspconfig")
    local dockerized = lspconfig.util.root_pattern("Dockerfile", "docker-compose.yml")(vim.fn.getcwd())

    if dockerized then
      local cutils = require("custom.utils")

      servers.ruby_lsp.cmd = {
        cutils.script_path("docker-cmd"),
        vim.env.DOCKER_CONTAINER,
        "ruby-lsp",
      }
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

      lspconfig[server].setup(server_setup)
    end
  end,
}
