return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'williamboman/mason.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = 'luvit-meta/library', words = { 'vim%.uv' } }
        }
      }
    }
  },
  config = function ()
    require('mason').setup()
    require('mason-lspconfig').setup()
    require('lazydev').setup()

    local servers = {
      lua_ls = {},
      solargraph = {},
      rubocop = {},
      rust_analyzer = {}
    }
    local ensure_installed = { 'lua_ls' }

    local lspconfig = require('lspconfig')
    lspconfig.util.on_setup = lspconfig.util.add_hook_before(lspconfig.util.on_setup, function(config)
      local cwd = vim.fn.getcwd()

      if string.find(cwd, "/Tirant/") then
        local dockerized_project = lspconfig.util.root_pattern('Dockerfile', 'docker-compose.yml')(cwd)

        if dockerized_project and config.name == 'rubocop' then
          config.cmd = { 'docker' ,'compose', 'exec', 'app', 'rubocop', '--lsp' }
        end
      end
    end)

    local function on_attach(_, buffer_n)
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, { buffer = buffer_n, desc = '[LSP] Telescope go to definition' })
      vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { buffer = buffer_n, desc = '[LSP] Telescope search document symbols' })
      vim.keymap.set('n', '<leader>sS', builtin.lsp_workspace_symbols, { buffer = buffer_n, desc = '[LSP] Telescope search workspace symbols' })
      vim.keymap.set('n', '<leader>sr', builtin.lsp_references, { buffer = buffer_n, desc = '[LSP] Telescope search references word under cursor' })
    end

    -- nvim-cmp capabilities (replaced by blink for now)
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local mason_lspconfig = require('mason-lspconfig')
    mason_lspconfig.setup({ ensure_installed = ensure_installed })
    mason_lspconfig.setup_handlers({
      function (server_name)
        local server_setup = { capabilities = capabilities, on_attach = on_attach }
        for key,value in pairs(servers[server_name]) do
          server_setup[key] = value
        end

        require('lspconfig')[server_name].setup(server_setup)
      end
    })
  end
}
