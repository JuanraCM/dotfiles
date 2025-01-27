return {
  "robitx/gp.nvim",
  config = function()
    require("gp").setup({
      openai_api_key = os.getenv("DEEPSEEK_API_KEY"),
      providers = {
        openai = {
          endpoint = "https://api.deepseek.com/chat/completions",
        },
        googleai = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
          secret = os.getenv("GOOGLEAI_API_KEY"),
        },
      },
      agents = {
        { name = "ChatGPT4o", disable = true },
        { name = "ChatGPT4o-mini", disable = true },
        { name = "CodeGPT4o", disable = true },
        { name = "CodeGPT4o-mini", disable = true },
        {
          provider = "googleai",
          name = "ChatGemini",
          chat = true,
          command = false,
          model = { model = "gemini-1.5-flash" },
          system_prompt = "You are a general AI assistant.",
        },
        {
          provider = "openai",
          name = "DeepSeekChat",
          chat = true,
          command = false,
          model = { model = "deepseek-chat", temperature = 0.0 },
          system_prompt = "You are a general AI assistant.",
        },
        {
          provider = "openai",
          name = "DeepSeekReasoner",
          chat = true,
          command = false,
          model = { model = "deepseek-reasoner" },
          system_prompt = "You are a general AI assistant.",
        },
      },
    })
  end,
}
