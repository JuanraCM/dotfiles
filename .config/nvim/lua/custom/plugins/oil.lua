return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      },
    })

    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("OilTelescope", { clear = true }),
      pattern = "oil",
      callback = function(evt)
        local cwd = vim.api.nvim_buf_get_name(0):gsub("^oil://", "")

        vim.keymap.set("n", "<leader>ff", function()
          require("telescope.builtin").find_files({ cwd = cwd, hidden = true })
        end, { buffer = evt.buf, desc = "Telescope find files" })
        vim.keymap.set("n", "<leader>fa", function()
          require("custom.telescope").live_multigrep({ cwd = cwd })
        end, { buffer = evt.buf, desc = "Telescope live multigrep" })
      end,
    })
  end,
}
