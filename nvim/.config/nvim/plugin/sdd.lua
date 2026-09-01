---@module "snacks"

local SPECS_FOLDER = ".specs"
local SPEC_FILE = "spec.md"

local ALLOWED_SUBCMDS = { "active", "archive" }

---@param specs_dir string
---@return snacks.picker.finder.Item[]
local retrieve_specs = function(specs_dir)
  local items = {}

  for name, ftype in vim.fs.dir(specs_dir) do
    if ftype == "directory" then
      items[#items + 1] = {
        text = name,
        file = vim.fs.joinpath(specs_dir, name, SPEC_FILE),
      }
    end
  end

  return items
end

---@param opts vim.api.keyset.create_user_command.command_args
local handle_specs_command = function(opts)
  local subcmd = opts.args

  if not vim.tbl_contains(ALLOWED_SUBCMDS, subcmd) then
    Snacks.notify.error("Subcommand not allowed")
    return
  end

  local dir = SPECS_FOLDER .. "/" .. subcmd
  local items = retrieve_specs(dir)

  if #items == 0 then
    Snacks.notify.warn(("No specs found"), { title = "Specs" })
    return
  end

  Snacks.picker.pick({
    title = ("Specs (%s)"):format(subcmd),
    items = items,
    format = "text",
  })
end

vim.api.nvim_create_user_command('Specs', handle_specs_command, {
  nargs = 1,
  complete = function() return ALLOWED_SUBCMDS end
})
