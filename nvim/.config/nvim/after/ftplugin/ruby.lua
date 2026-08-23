vim.keymap.set("v", "<leader>m", function()
  require("custom.ruby-mp").monkeypatch()
end, { buffer = true, desc = "Monkeypatch ruby class" })
