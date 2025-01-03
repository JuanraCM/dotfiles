local M = {}

M.script_path = function (fname)
  local path = {
    vim.fn.stdpath('config'),
    'scripts',
    fname
  }

  return table.concat(path, '/')
end

return M
