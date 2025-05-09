return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    -- This module is required to allow asynchronous programming using coroutines
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")
      local custom = require("custom.telescope")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { ".git/", ".node_modules" },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
        },
        pickers = {
          git_commits = {
            mappings = {
              i = {
                ["<c-v>"] = function(prompt_bufnr)
                  local entry = state.get_selected_entry()
                  local commit_hash = entry.value

                  actions.close(prompt_bufnr)
                  vim.cmd("vertical Git show " .. commit_hash)
                end,
              },
            },
          },
        },
      })

      pcall(telescope.load_extension, "fzf")

      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files({ hidden = true })
      end, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>fa", custom.live_multigrep, { desc = "Telescope live multigrep" })
      vim.keymap.set("n", "<leader>fA", function()
        builtin.live_grep({ grep_open_files = true })
      end, { desc = "Telescope live multigrep" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep word under cursor" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Telescope find git files" })
      vim.keymap.set("n", "<leader>fc", builtin.git_commits, { desc = "Telescope find git commits" })
      vim.keymap.set("n", "<leader>fC", builtin.git_bcommits, { desc = "Telescope find buffer's git commits" })
      vim.keymap.set("n", "<leader>fb", builtin.git_branches, { desc = "Telescope find git branches" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope find help tags" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope find keymaps" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Telescope find diagnostics" })
      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
        })
      end, { desc = "Telescope find nvim config" })
      vim.keymap.set("n", "<leader>fp", function()
        builtin.find_files({
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
        })
      end, { desc = "Telescope find nvim plugins" })
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Fuzzily search in current buffer" })
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
