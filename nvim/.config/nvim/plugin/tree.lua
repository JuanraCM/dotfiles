local icons = require("mini.icons")

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

local function get_icon(entry_name, is_dir)
  local category = is_dir and "directory" or "extension"
  local icon, hl_group = icons.get(category, entry_name)

  return icon .. " ", hl_group
end

local function format_tree(original_tree)
  local lines = {}
  local paths = {}
  local highlights = {}

  local function format_lines(tree, prefix, path)
    local entries = sorted_entries(tree)

    for _, entry in ipairs(entries) do
      local children = tree[entry]
      local is_dir = next(children)

      entry = is_dir and entry .. "/" or entry
      local icon, icon_hl = get_icon(entry, is_dir)

      table.insert(lines, prefix .. icon .. entry)
      table.insert(paths, path .. entry)
      table.insert(highlights, { "Comment", #lines - 1, 0, #prefix })
      table.insert(highlights, { icon_hl, #lines - 1, #prefix, #prefix + #icon })

      if is_dir then
        table.insert(highlights, { "Directory", #lines - 1, #prefix + #icon, -1 })
        format_lines(children, prefix .. "▎  ", path .. entry)
      end
    end

    return lines
  end

  format_lines(original_tree, "", "")

  return lines, paths, highlights
end

local function show_tree()
  local output = vim.fn.system("git ls-files")
  local raw_lines = vim.split(output, "\n", { trimempty = true })
  local tree = build_tree(raw_lines)

  local lines, paths, highlights = format_tree(tree)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("Tree")
  local augroup = vim.api.nvim_create_augroup("Tree", { clear = true })

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, unpack(hl))
  end

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    buffer = buf,
    callback = function(_)
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      local path = paths[lnum]

      vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, -1, {
        id = 1,
        virt_text = { { path, "Comment" } },
      })
    end,
  })

  vim.keymap.set("n", "<cr>", function()
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local path = paths[lnum]

    vim.cmd(":e " .. path)
  end, { buffer = buf })

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("Tree", show_tree, {})
