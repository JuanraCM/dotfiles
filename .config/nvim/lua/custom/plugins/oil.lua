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

    ---@module 'snacks'
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("OilPicker", { clear = true }),
      pattern = "oil",
      callback = function(evt)
        local cwd = vim.api.nvim_buf_get_name(0):gsub("^oil://", "")

        vim.keymap.set("n", "<leader>ff", function()
          Snacks.picker.files({ cwd = cwd })
        end, { buffer = evt.buf, desc = "Oil find files" })
        vim.keymap.set("n", "<leader>fa", function()
          Snacks.picker.grep({ cwd = cwd })
        end, { buffer = evt.buf, desc = "Oil grep" })
      end,
    })
  end,
}
