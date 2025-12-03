---@module "snacks"

local TASKS_DIR = vim.fs.joinpath(vim.fn.stdpath("data"), "tasks")

local function ensure_tasks_dir()
  if vim.fn.isdirectory(TASKS_DIR) == 0 then
    vim.fn.mkdir(TASKS_DIR)
  end
end

local function list_tasks()
  local tasks = vim.fn.readdir(TASKS_DIR)
  if vim.tbl_isempty(tasks) then
    print("No tasks found.")
    return
  end

  Snacks.picker.files({
    title = "Tasks",
    cwd = TASKS_DIR,
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "delete_files", mode = { "n", "i" } },
        },
      },
    },
  })
end

local function new_task()
  Snacks.input({ prompt = "Enter task name" }, function(task_name)
    if not task_name or task_name == "" then
      print("Task name cannot be empty.")
      return
    end

    local current_date = os.date("%Y-%m-%d")
    local task_file = TASKS_DIR .. "/" .. current_date .. "-" .. task_name .. ".md"
    if vim.fn.filereadable(task_file) == 1 then
      print("Task already exists.")
      return
    end

    vim.cmd("edit " .. task_file)
  end)
end

vim.api.nvim_create_user_command("Tasks", function(cmd)
  ensure_tasks_dir()

  if cmd.args == "" or cmd.args == "list" then
    list_tasks()
  elseif cmd.args == "new" then
    new_task()
  else
    print("Usage: :Tasks [list|new]")
  end
end, {
  desc = "AI Task manager",
  nargs = "?",
  complete = function()
    return { "list", "new" }
  end,
})
