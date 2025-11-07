local M = {}

---@param node TSNode
---@return TSNode[]
local function get_parents(node, parents)
  local node_parent = node:parent()

  if not node_parent then
    return parents
  end

  if node_parent:type() == "class" or node_parent:type() == "module" then
    table.insert(parents, node_parent)
  end

  return get_parents(node_parent, parents)
end

---@param parents TSNode[]
---@return { head: string[], tail: string[] }
local function get_lines(parents)
  local lines = { head = {}, tail = {} }

  for _, parent in ipairs(parents) do
    local pstart_line = parent:start()
    local pend_line = parent:end_()

    local first_line = vim.api.nvim_buf_get_lines(0, pstart_line, pstart_line + 1, false)[1]
    local last_line = vim.api.nvim_buf_get_lines(0, pend_line, pend_line + 1, false)[1]

    table.insert(lines.head, 1, first_line)
    table.insert(lines.tail, last_line)
  end

  return lines
end

---@param line_offset number
---@return number, number
local function calc_lines(line_offset)
  local cline, vline = vim.fn.getpos(".")[2], vim.fn.getpos("v")[2]

  local start_line = math.min(cline, vline) - 1
  local end_line = math.max(cline, vline) + line_offset

  return start_line, end_line
end

---Inserts monkeypatch for the current class or module
M.monkeypatch = function()
  local current_node = vim.treesitter.get_node()

  if not current_node then
    return
  end

  local parents = get_parents(current_node, {})
  local lines_to_insert = get_lines(parents)
  local start_line, end_line = calc_lines(#lines_to_insert.head)

  vim.api.nvim_buf_set_lines(0, start_line, start_line, false, lines_to_insert.head)
  vim.api.nvim_buf_set_lines(0, end_line, end_line, false, lines_to_insert.tail)
end

return M
