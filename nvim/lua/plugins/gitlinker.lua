return {
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>gB", false },
      { "<leader>gY", false },
    },
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "x" }, desc = "Copy Git Permalink" },
      { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "x" }, desc = "Open Git Permalink" },
      { "<leader>gB", "<cmd>GitLink! default_branch<cr>", desc = "Open Repository Homepage" },
    },
  },
}
