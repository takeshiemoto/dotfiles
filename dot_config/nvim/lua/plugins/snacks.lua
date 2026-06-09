return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
          auto_close = false,
          follow_file = false,
        },
      },
    },
  },
}
