local ENV_FILE = ".nvim-env.json"
local ENV_VARS = { "DOCKER_CONTAINER", "DISABLE_LSP_SERVERS" }

local load_env = function()
  if vim.fn.filereadable(ENV_FILE) == 0 then
    return
  end

  local lines = vim.fn.readfile(ENV_FILE)
  local content = table.concat(lines, "\n")
  local env_config = vim.json.decode(content)

  for _, key in ipairs(ENV_VARS) do
    vim.env[key] = env_config[key]
  end
end

load_env()
