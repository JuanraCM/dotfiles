local function bdd_task_id()
  local branch_name = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait().stdout
  local task_id = branch_name and vim.split(branch_name, "-")[2] or "UNKNOWN"

  return task_id
end

local snippets = {
  s(
    { trig = "bdd", desc = "Tirant BDD commit message" },
    fmt(
      [[
        [BDD-{}] {}
      ]],
      { f(bdd_task_id), i(1, "Commit Message") }
    )
  ),
}

return snippets
