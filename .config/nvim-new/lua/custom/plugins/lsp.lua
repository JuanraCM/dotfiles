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

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    require('lspconfig').lua_ls.setup({
      capabilities = capabilities
    })
    require('lspconfig').rubocop.setup({
      capabilities = capabilities
    })
  end
}
