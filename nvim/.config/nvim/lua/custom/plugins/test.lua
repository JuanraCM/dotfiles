return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "neovim_sticky"
    vim.g["test#neovim#term_position"] = "vert"

    if vim.env.DOCKER_CONTAINER then
      vim.g["test#custom_transformations"] = {
        docker = function(cmd)
          return table.concat({
            require("custom.utils").script_path("docker-cmd"),
            vim.env.DOCKER_CONTAINER,
            cmd,
          }, " ")
        end
      }
      vim.g["test#transformation"] = "docker"
    end

    vim.keymap.set("n", "<leader>rf", ":TestFile<cr>", { desc = "Run test file" })
    vim.keymap.set("n", "<leader>rt", ":TestNearest<cr>", { desc = "Run nearest test" })
    vim.keymap.set("n", "<leader>rl", ":TestLast<cr>", { desc = "Run last test" })
    vim.keymap.set("n", "<leader>ra", ":TestSuite<cr>", { desc = "Run all tests" })
  end,
}
