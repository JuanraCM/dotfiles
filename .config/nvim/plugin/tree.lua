local function build_tree(lines)
  local tree = {}

  for _, line in ipairs(lines) do
    local parts = vim.split(line, "/")
    local node = tree

    for _, part in ipairs(parts) do
      node[part] = node[part] or {}
      node = node[part]
    end
  end

  return tree
end

local function sorted_entries(tree)
  local entries = vim.tbl_keys(tree)
  table.sort(entries)

  local dirs, files = {}, {}

  for _, entry in ipairs(entries) do
    local list = next(tree[entry]) and dirs or files
    table.insert(list, entry)
  end

  return vim.list_extend(dirs, files)
end

-- TEMP
local current_line = 0
local highlights = {}
--
local function format_tree(tree, prefix)
  local lines = {}
  local entries = sorted_entries(tree)

  for _, entry in ipairs(entries) do
    local to_insert = prefix .. entry
    local children = tree[entry]
    local is_dir = next(children)

    table.insert(highlights, { "Comment", current_line, 0, #prefix })
    if is_dir then
      table.insert(highlights, { "Directory", current_line, #prefix, -1 })
    end
    current_line = current_line + 1

    if is_dir then
      table.insert(lines, to_insert .. "/")
      vim.list_extend(lines, format_tree(children, prefix .. "▎  "))
    else
      table.insert(lines, to_insert)
    end
  end

  return lines
end

local function show_tree()
  local output = vim.fn.system("git ls-files")
  local lines = vim.split(output, "\n", { trimempty = true })
  local tree = build_tree(lines)
  local formatted = format_tree(tree, "")

  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)

  local ns = vim.api.nvim_create_namespace("ShowTree")
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, unpack(hl))
  end

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("ShowTree", show_tree, {})
