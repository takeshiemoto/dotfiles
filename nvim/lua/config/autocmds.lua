-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local group = vim.api.nvim_create_augroup("jetbrains_like_autosave", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusLost", "BufLeave" }, {
  group = group,
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.bo.modifiable and not vim.bo.readonly then
      vim.cmd("silent! write")
    end
  end,
})
