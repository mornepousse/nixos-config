-- Configuration minimale clangd pour C++
-- CMake génère compile_commands.json avec les chemins Qt automatiquement

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = { "clangd", "--background-index" },
        },
      },
    },
  },
}
