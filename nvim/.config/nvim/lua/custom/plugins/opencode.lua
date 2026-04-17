return {
  "NickvanDyke/opencode.nvim",
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          local cmd = "opencode --port"
          local percent = 35

          vim.fn.system(string.format("tmux split-window -h -f -d -p %d -- %s", percent, cmd))
        end,
      },
    }

    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-S-O>", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-O>", function()
      require("opencode").start()
    end, { desc = "Start opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })
  end,
}
