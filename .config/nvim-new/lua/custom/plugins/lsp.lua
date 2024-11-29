return {
  'neovim/nvim-lspconfig',
  'williamboman/mason-lspconfig.nvim',
  {
    'williamboman/mason.nvim',
    config = function ()
      require('mason').setup()
      require('mason-lspconfig').setup()

      require('lspconfig').lua_ls.setup({})
      require('lspconfig').rubocop.setup({})
    end
  }
}
