local claude = require("custom.claude")

return {
  "coder/claudecode.nvim",
  config = function(_, opts)
    require("claudecode").setup(opts)

    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("ClaudeCodeChecktime", { clear = true }),
      desc = "Reload buffers changed on disk by Claude Code",
      command = "silent! checktime",
    })
  end,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    { "<leader>a",  nil,                              desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
    {
      "<leader>at",
      function()
        local task = vim.api.nvim_get_current_line():match("T[0-9]+")

        if not task then
          return
        end

        local spec_name = vim.fs.basename(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        local prompt = ("/sdd-impl %s %s"):format(spec_name, task)

        claude.send(prompt)
      end,
      ft = "markdown",
      desc = "Implement spec task with Claude",
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
  },
  opts = {
    terminal = {
      provider = {
        setup = claude.setup,
        is_available = claude.is_available,
        open = claude.open,
        close = claude.close,
        simple_toggle = claude.simple_toggle,
        focus_toggle = claude.focus_toggle,
        toggle = claude.toggle,
        ensure_visible = claude.ensure_visible,
        get_active_bufnr = claude.get_active_bufnr,
      },
    },
  },
}
