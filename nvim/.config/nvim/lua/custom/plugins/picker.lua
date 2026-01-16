---@module 'snacks'

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      actions = {
        git_merge = function(picker, item)
          if not (item and item.branch) then
            Snacks.notify.warn("No branch or commit found", { title = "Snacks Picker" })
          end

          local branch = item.branch
          Snacks.picker.util.cmd({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, function(data)
            if data[1]:match(branch) ~= nil then
              Snacks.notify.error("Cannot delete the current branch.", { title = "Snacks Picker" })
              return
            end

            Snacks.picker.select({ "Yes", "No" }, { prompt = ("Merge branch %q?"):format(branch) }, function(_, idx)
              if idx == 1 then
                Snacks.picker.util.cmd({ "git", "merge", branch }, function()
                  Snacks.notify("Merged Branch `" .. branch .. "`", { title = "Snacks Picker" })
                  vim.cmd.checktime()
                  picker:close()
                end, { cwd = picker:cwd() })
              end
            end)
          end, { cwd = picker:cwd() })
        end,
        git_view_file = function(picker, item)
          if not (item and item.commit) then
            Snacks.notify.warn("No branch or commit found", { title = "Snacks Picker" })
          end

          picker:close()

          vim.cmd.Gvsplit(item.commit .. ":%")
        end,
        delete_files = function(picker)
          for _, item in ipairs(picker:selected({ fallback = true })) do
            if item.file then
              vim.fn.delete(item._path)
            end
          end

          picker:find()
        end,
      },
    },
    explorer = {},
  },
  keys = {
    {
      "<leader><leader>",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files({ hidden = true })
      end,
      desc = "Find files",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.grep({ hidden = true })
      end,
      desc = "Grep",
    },
    {
      "<leader>fw",
      function()
        Snacks.picker.grep_word({ hidden = true })
      end,
      mode = { "n", "v" },
      desc = "Grep visual selection or word",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.lines()
      end,
      desc = "Grep current buffer lines",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.git_log({
          win = {
            input = {
              keys = {
                ["<c-v>"] = { "git_view_file", mode = { "n", "i" } },
              },
            },
          },
        })
      end,
      desc = "Git commits",
    },
    {
      "<leader>fC",
      function()
        Snacks.picker.git_log_file({
          win = {
            input = {
              keys = {
                ["<c-v>"] = { "git_view_file", mode = { "n", "i" } },
              },
            },
          },
        })
      end,
      desc = "Git commits current file",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_status({
          win = {
            input = {
              keys = {
                ["<c-r>"] = { "git_restore", mode = { "n", "i" } },
              },
            },
          },
        })
      end,
      desc = "Git status",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.git_branches({
          win = {
            input = {
              keys = {
                ["<c-y>"] = { "git_merge", mode = { "n", "i" } },
                ["<c-v>"] = { "git_view_file", mode = { "n", "i" } },
              },
            },
          },
        })
      end,
      desc = "Git branches",
    },
    {
      "<leader>fh",
      function()
        Snacks.picker.help()
      end,
      desc = "Help tags",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>fd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>fD",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Diagnostics current file",
    },
    {
      "<leader>fn",
      function()
        Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "Find nvim config",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
      end,
      desc = "Find nvim plugins",
    },
    {
      "<c-e>",
      function()
        Snacks.explorer()
      end,
      desc = "Toggle Explorer",
    },
  },
}
