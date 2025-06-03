---@module 'snacks'

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {},
  },
  keys = {
    {
      "<leader><leader>",
      function()
        Snacks.picker.buffers({
          on_show = function()
            vim.cmd.stopinsert()
          end,
        })
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
        Snacks.picker.git_log()
      end,
      desc = "Git commits",
    },
    {
      "<leader>fC",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "Git commits current file",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.git_branches()
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
  },
}
