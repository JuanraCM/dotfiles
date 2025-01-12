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

local function format_tree(tree, prefix)
  local lines = {}

  for name, children in pairs(tree) do
    table.insert(lines, prefix .. name)

    if type(children) == "table" and next(children) then
      vim.list_extend(lines, format_tree(children, prefix .. "|  "))
    end
  end

  return lines
end

local function show_tree()
  local output = vim.fn.system("git ls-files")
  local lines = vim.split(output, "\n", { trimempty = true })
  local tree = build_tree(lines)

  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, format_tree(tree, ""))
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("ShowTree", show_tree, {})
