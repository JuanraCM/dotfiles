local M = {}

M.script_path = function(fname, env)
  local path = table.concat({
    vim.fn.stdpath("config"),
    "scripts",
    fname,
  }, "/")

  local formatted_env = ""
  for key, value in pairs(env) do
    formatted_env = formatted_env .. key .. "=" .. value .. " "
  end

  return formatted_env .. path
end

return M
