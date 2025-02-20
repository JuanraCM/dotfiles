local M = {}

local ENV_FILE = ".nvim.env"
local ENV_DEFAULTS = {
  DOCKER_CONTAINER = "app",
}

M.load_env = function()
  for key, value in pairs(ENV_DEFAULTS) do
    vim.env[key] = value
  end

  if vim.fn.filereadable(ENV_FILE) == 1 then
    for line in io.lines(ENV_FILE) do
      local key, value = line:match("^(.-)=(.*)$")

      vim.env[key] = value
    end
  end
end

M.script_path = function(fname)
  return table.concat({
    vim.fn.stdpath("config"),
    "scripts",
    fname,
  }, "/")
end

return M
