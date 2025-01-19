return {
  "robitx/gp.nvim",
  config = function()
    require("gp").setup({
      openai_api_key = "",
      providers = {
        openai = {},
        googleai = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
          secret = os.getenv("GOOGLEAI_API_KEY"),
        },
      },
      agents = {
        { name = "ChatGemini", disable = true },
        {
          provider = "googleai",
          name = "Gemini",
          chat = true,
          command = false,
          model = { model = "gemini-1.5-flash" },
          system_prompt = require("gp.defaults").chat_system_prompt,
        },
      },
    })
  end,
}
