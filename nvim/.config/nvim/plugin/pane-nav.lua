local wezterm_directions = { h = "Left", j = "Down", k = "Up", l = "Right" }
local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }
local herdr_directions = { h = "left", j = "down", k = "up", l = "right" }

local function at_edge(direction)
  return vim.fn.winnr() == vim.fn.winnr(direction)
end

local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

local function in_herdr()
  return vim.env.HERDR_PANE_ID ~= nil and vim.env.HERDR_PANE_ID ~= ""
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

local function send_key_to_tmux(direction)
  vim.fn.system({ "tmux", "select-pane", "-" .. tmux_directions[direction] })
end

local function send_key_to_herdr(direction)
  local herdr = vim.env.HERDR_BIN_PATH
  if herdr == nil or herdr == "" then
    herdr = "herdr"
  end

  vim.fn.system({ herdr, "pane", "focus", "--direction", herdr_directions[direction], "--pane", vim.env.HERDR_PANE_ID })
end

local function move(direction)
  if at_edge(direction) then
    if in_herdr() then
      send_key_to_herdr(direction)
    elseif in_tmux() then
      send_key_to_tmux(direction)
    else
      send_key_to_wezterm(direction)
    end
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
