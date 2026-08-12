return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
        virtual_lines = { current_line = true },
      },
      servers = {
        phpactor = { enabled = false },
        intelephense = {
          enabled = true,
        },
      },
    },
  },
}
