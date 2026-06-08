return {
  { "LazyVim/LazyVim", opts = { colorscheme = "vague" } },
  {
    "vague2k/vague.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vague").setup({})
    end,
  },
}
