return {
  enabled = false,
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-nvim-lsp',
    'onsails/lspkind.nvim'
  },
  config = function ()
    local cmp = require('cmp')
    local lspkind = require('lspkind')

    cmp.setup({
      mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item() else fallback() end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item() else fallback() end
        end, { 'i', 's' })
      },
      sources = {
        { name = 'lazydev', group_index = 0 },
        { name = 'codeium' },
        { name = 'nvim_lsp' },
        { name = 'buffer' }
      },
      formatting = {
        expandable_indicator = true,
        fields = { 'abbr', 'kind', 'menu' },
        format = lspkind.cmp_format({
          menu = {
            lazydev = '[DEV]',
            nvim_lsp = '[LSP]',
            buffer = '[BUF]',
            codeium = '[IA]'
          },
          symbol_map = {
            Codeium = '󱡄'
          }
        })
      }
    })
  end
}
