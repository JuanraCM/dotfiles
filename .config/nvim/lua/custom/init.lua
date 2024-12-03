require("custom.set")
require("custom.remap")
require("custom.lazy")
require("custom.stuff")

local cwd = vim.fn.getcwd()
if string.find(cwd, "/Tirant/") then
  require("custom.workspace.tirant")
end
