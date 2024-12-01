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
      ruby_lsp = {},
      rubocop = {}
    }

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    local lsp_config = require('mason-lspconfig')

    lsp_config.setup({ ensure_installed = vim.tbl_keys(servers) })

    lsp_config.setup_handlers({
      function (server_name)
        local server_setup = { capabilities = capabilities }
        for key,value in pairs(servers[server_name]) do
          server_setup[key] = value
        end

        require('lspconfig')[server_name].setup(server_setup)
      end
    })
  end
}
