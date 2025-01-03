return {
  'mfussenegger/nvim-lint',
  config = function ()
    local lint = require('lint')
    local cutils = require('custom.utils')

    lint.linters_by_ft = {
      ruby = { 'rubocop' }
    }

    lint.linters.rubocop.cmd = cutils.script_path('docker-rubocop')
    lint.linters.rubocop.args = {
      '--format',
      'json',
      '--force-exclusion',
      '--stdin',
      function() return vim.fn.expand('%') end,
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
      group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
      callback = function ()
        lint.try_lint()
      end
    })
  end
}
