vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true }

map("n", "s", "", opt)
map("n", "<leader>fs", ":w<cr>", opt)
map("n", "<leader>ff", ":e ", opt)
map("n", "<leader><cr>", ":noh<cr>", opt)
map("n", "Y", "y$", opt)

map("n", "<leader>w", "<c-w>", opt)
map("n", "<leader>wd", "<c-w>c", opt)

map("v", "<leader>y", '"+y', opt)
map("v", "<leader>p", '"+p', opt)
map("v", "//", "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", opt)

map("i", "jk", "<esc>", opt)
map("i", "<c-f>", "<right>", opt)
map("i", "<c-b>", "<left>", opt)
map("i", "<c-g>", "<esc>", opt)

