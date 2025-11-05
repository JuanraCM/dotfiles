local JIRA_BASE_URL = "https://tirantmodulos.atlassian.net/browse/"

local function fetch_current_line_commit()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local file = vim.api.nvim_buf_get_name(0)
  local commit_msg = vim.fn.system({
    "git",
    "log",
    "--format=%s",
    "-L",
    tostring(line_num) .. "," .. tostring(line_num) .. ":" .. file,
    "-n",
    "1",
    "--quiet",
  })

  if vim.v.shell_error ~= 0 or #commit_msg == 0 then
    return nil
  end

  return commit_msg:gsub("\n$", "")
end

local function find_jira_issue_key(commit_msg)
  local pattern = "([A-Z]+)-?(%d+)"
  local issue_group, issue_number = commit_msg:match(pattern)

  if not issue_group or not issue_number then
    return nil
  end

  return issue_group .. "-" .. issue_number
end

local function browse_jira_url()
  local line_commit_msg = fetch_current_line_commit()

  if not line_commit_msg then
    vim.notify("No commit message found on the current line", vim.log.levels.WARN)
    return
  end

  local jira_issue_key = find_jira_issue_key(line_commit_msg)

  if not jira_issue_key then
    vim.notify("No JIRA issue key found in the commit message", vim.log.levels.WARN)
    return
  end

  local jira_url = JIRA_BASE_URL .. jira_issue_key

  vim.notify("Opening JIRA issue: " .. jira_url, vim.log.levels.INFO)
  vim.ui.open(jira_url)
end

vim.keymap.set("n", "<leader>gj", browse_jira_url, { desc = "Browse Jira URL" })
