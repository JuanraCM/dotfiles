return {
  "vim-test/vim-test",
  config = function()
    local function docker_transform(cmd)
      local docker_call = require("custom.utils").script_path("docker-container", {
        DOCKER_CONTAINER = vim.env.DOCKER_CONTAINER,
      })

      return docker_call .. " " .. cmd
    end

    vim.g["test#custom_transformations"] = { docker = docker_transform }
    vim.g["test#transformation"] = "docker"
    vim.g["test#strategy"] = "neovim_sticky"

    vim.g["test#neovim#term_position"] = "vert"

    -- Jest config
    vim.g["test#javascript#jest#executable"] = "yarn test"

    vim.keymap.set("n", "<leader>rf", ":TestFile<cr>", { desc = "Run test file" })
    vim.keymap.set("n", "<leader>rt", ":TestNearest<cr>", { desc = "Run nearest test" })
    vim.keymap.set("n", "<leader>rl", ":TestLast<cr>", { desc = "Run last test" })
    vim.keymap.set("n", "<leader>ra", ":TestSuite<cr>", { desc = "Run all tests" })
  end,
}
