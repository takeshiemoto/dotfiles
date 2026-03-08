-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>hh", function()
  Snacks.dashboard()
end, { desc = "Home" })

local function copy_to_system_clipboard(value, label)
  vim.fn.setreg("+", value)
  vim.notify("Copied " .. label .. ": " .. value)
end

vim.keymap.set("n", "<leader>yp", function()
  copy_to_system_clipboard(vim.fn.expand("%:p"), "absolute path")
end, { desc = "Copy Absolute Path" })

vim.keymap.set("n", "<leader>yr", function()
  copy_to_system_clipboard(vim.fn.expand("%:."), "relative path")
end, { desc = "Copy Relative Path" })

vim.keymap.set("n", "<leader>yf", function()
  copy_to_system_clipboard(vim.fn.expand("%:t"), "file name")
end, { desc = "Copy Filename" })

vim.keymap.set("n", "<leader>yl", function()
  copy_to_system_clipboard(vim.fn.expand("%:.") .. ":" .. vim.fn.line("."), "relative path:line")
end, { desc = "Copy Relative Path with Line" })
