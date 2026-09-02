local M = {}

local AGENT_CMD = "claude"
local PANE_WIDTH = 35

local agent_ttys = function()
  local ttys = {}

  for line in vim.fn.system("ps -eo tty=,args="):gmatch("[^\n]+") do
    local tty, args = line:match("^(%S+)%s+(.*)$")
    local argv0 = args and args:match("^%S+")

    if tty and tty ~= "?" and argv0 and vim.fs.basename(argv0):match(AGENT_CMD) then
      ttys[tty] = true
    end
  end

  return ttys
end

local find_agent_pane = function()
  local ttys = agent_ttys()
  local output = vim.fn.system("tmux list-panes -F '#{pane_tty} #{pane_id}'")

  for line in output:gmatch("[^\n]+") do
    local pane_tty, pane_id = line:match("^(%S+)%s+(%S+)$")
    local tty = pane_tty and pane_tty:gsub("^/dev/", "")

    if tty and ttys[tty] then
      return pane_id
    end
  end

  return nil
end

local open_agent = function()
  local output = vim.fn.system(
    string.format("tmux split-window -d -h -f -p %d -F '#{pane_id}' -P -- %s", PANE_WIDTH, AGENT_CMD)
  )
  return vim.fn.trim(output)
end

---@param cmd string
M.send_agent_command = function(cmd)
  local pane_id = find_agent_pane() or open_agent()

  vim.fn.system(string.format("tmux send-keys -t %s '%s '", pane_id, cmd))
end

return M
