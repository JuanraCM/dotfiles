return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function lsp_clients()
      local icon = " "
      local clients = vim.lsp.get_clients()
      if next(clients) == nil then
        return icon .. "No LSP"
      end

      local client_names = {}
      for i = 1, #clients, 1 do
        table.insert(client_names, clients[i].name)
      end

      return icon .. table.concat(client_names, ", ")
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "tokyonight",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_y = { lsp_clients },
      },
    })
  end,
}
