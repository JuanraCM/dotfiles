---@module "snacks"

return {
  "rest-nvim/rest.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  ft = { "http" },
  keys = {
    { "<cr>", ":Rest run<cr>", desc = "Run REST request under cursor", ft = "http" },
    { "<c-e>", ":Rest env select<cr>", desc = "Select REST environment", ft = "http" },
    {
      "<c-cr>",
      function()
        local request_names = require("rest-nvim.parser").get_request_names(0)

        Snacks.picker.select(request_names, {
          prompt = "Select REST request to run",
        }, function(selected)
          local escaped_name = selected:gsub(" ", "\\ ")
          vim.cmd("Rest run " .. escaped_name)
        end)
      end,
      desc = "Run REST request by name",
      ft = "http",
    },
  },
}
