return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        slint_lsp = {},
      },
    },
  },
  -- Coloration syntaxique Slint
  {
    "slint-ui/vim-slint",
    ft = "slint",
  },
}
