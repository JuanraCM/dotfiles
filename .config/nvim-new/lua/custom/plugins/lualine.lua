return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function ()
    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = ''
      },
      sections = {
        lualine_a = {
          { 'buffers' }
        },
        lualine_c = {}
      }
    })
  end
}
