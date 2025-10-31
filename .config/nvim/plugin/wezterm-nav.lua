local wezterm_directions = { h = "Left", j = "Down", k = "Up", l = "Right" }

local function at_edge(direction)
  return vim.fn.winnr() == vim.fn.winnr(direction)
end

local function wezterm_exec(cmd)
  local command = vim.deepcopy(cmd)
  if vim.fn.executable("wezterm.exe") == 1 then
    table.insert(command, 1, "wezterm.exe")
  else
    table.insert(command, 1, "wezterm")
  end
  table.insert(command, 2, "cli")
  return vim.fn.system(command)
end

local function send_key_to_wezterm(direction)
  wezterm_exec({ "activate-pane-direction", wezterm_directions[direction] })
end

local function move(direction)
  if at_edge(direction) then
    send_key_to_wezterm(direction)
  else
    vim.cmd("wincmd " .. direction)
  end
end

vim.keymap.set("n", "<C-h>", function()
  move("h")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", function()
  move("j")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", function()
  move("k")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", function()
  move("l")
end, { noremap = true, silent = true })
