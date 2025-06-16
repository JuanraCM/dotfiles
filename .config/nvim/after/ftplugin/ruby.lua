vim.api.nvim_buf_create_user_command(0, "RubocopFixAll", function(evt)
  local formatter = evt.bang and "rubocop_unsafe" or "rubocop"

  require("conform").format({
    formatters = { formatter },
    timeout_ms = 10000,
  })
end, { bang = true, desc = "Fix all rubocop offenses" })

vim.keymap.set("v", "<leader>m", function()
  local tree = vim.treesitter.get_parser():parse()[1]
  local root = tree:root()
  local class_name = nil

  for node in root:iter_children() do
    if node:type() == "class" then
      class_name = vim.treesitter.get_node_text(node:field("name")[1], 0)
      break
    end
  end

  if not class_name then
    return
  end

  local start_line = vim.fn.getpos("v")[2] - 1
  local end_line = vim.fn.getpos(".")[2] + 1

  vim.api.nvim_buf_set_lines(0, start_line, start_line, false, { "class " .. class_name })
  vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { "end" })
end, { desc = "Monkeypatch ruby class" })
