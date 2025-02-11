local ENV_FILE = ".nvim.env"

local function load_env()
  if vim.fn.filereadable(ENV_FILE) == 1 then
    for line in io.lines(ENV_FILE) do
      local key, value = line:match("^(.-)=(.*)$")

      vim.env[key] = value
    end
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("NvimEnvLoad", { clear = true }),
  callback = load_env,
})
