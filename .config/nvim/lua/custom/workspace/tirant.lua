print("Loading Tirant workspace specifics...")

-- Changes default Rubocop CMD to use the docker container one instead (if dockerized)
local lspconfig = require('lspconfig')

lspconfig.util.on_setup = lspconfig.util.add_hook_before(lspconfig.util.on_setup, function(config)
  local dockerized_project = lspconfig.util.root_pattern('Dockerfile', 'docker-compose.yml')(vim.fn.getcwd())

  if dockerized_project and config.name == 'rubocop' then
    config.cmd = { 'docker' ,'compose', 'exec', 'app', 'rubocop', '--lsp' }
  end
end)

lspconfig['rubocop'].setup({})
