---@module "snacks"

local SPECS_FOLDER = ".specs"
local SPEC_FILE = "spec.md"

local ALLOWED_SUBCMDS = { "active", "archive" }

local claude = require("custom.claude")

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

local handle_specs_keymap = function()
  local cline = vim.api.nvim_get_current_line()
  local match = cline:match("T[0-9]+")

  if not match then
    return
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  local spec_name = vim.fs.basename(vim.fs.dirname(file_name))
  local cmd = ("/sdd-impl %s %s"):format(spec_name, match)

  claude.send_agent_command(cmd)
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup("SDD", { clear = true }),
  pattern = "*",
  callback = function(ev)
    if not ev.file:match(SPECS_FOLDER) then
      return
    end

    vim.keymap.set("n", "gA", handle_specs_keymap, { buf = ev.buf })
  end
})

vim.api.nvim_create_user_command('Specs', handle_specs_command, {
  nargs = 1,
  complete = function() return ALLOWED_SUBCMDS end
})
