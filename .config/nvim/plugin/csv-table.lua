local function fetch_csv_lines()
  local filename = vim.api.nvim_buf_get_name(0)
  local file = io.open(filename, "r")

  if not file then
    vim.notify("Could not open file: " .. filename, vim.log.levels.ERROR)
    return
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  return lines
end

local function parse_csv_lines(lines)
  local csv_data = {}

  for _, line in ipairs(lines) do
    local row = {}
    for value in string.gmatch(line, "([^,]+)") do
      table.insert(row, value)
    end

    table.insert(csv_data, row)
  end

  return csv_data
end

local function format_csv_lines(csv_data)
  local csv_lines = {}
  local col_widths = {}

  for _, row in ipairs(csv_data) do
    for i, cell in ipairs(row) do
      col_widths[i] = math.max(col_widths[i] or 0, string.len(cell))
    end
  end

  for _, row in ipairs(csv_data) do
    local row_string = ""
    for i, cell in ipairs(row) do
      local padding = col_widths[i] - string.len(cell)
      row_string = row_string .. cell .. string.rep(" ", padding) .. " ▎"
    end

    table.insert(csv_lines, row_string)
  end

  return csv_lines
end

local function show_csv_table()
  local csv_lines = fetch_csv_lines()
  local csv_data = parse_csv_lines(csv_lines)
  local formatted_lines = format_csv_lines(csv_data)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_lines)

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_current_buf(buf)
end

vim.api.nvim_create_user_command("CSVTable", show_csv_table, {})
