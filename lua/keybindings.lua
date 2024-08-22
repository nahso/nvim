vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map("n", "q:", "", opt)
map("n", "s", "", opt)
map("n", "<leader>fs", ":w<cr>", opt)
--map("n", "<leader>ff", ":e ", opt)
map("n", "<leader><cr>", ":noh<cr>", opt)
map("n", "Y", "y$", opt)

map("n", "<leader>w", "<c-w>", opt)
map("n", "<leader>wd", "<c-w>c", opt)

map("v", "<leader>y", '"+y', opt)
map("v", "<leader>p", '"+p', opt)
map("v", "//", "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", opt)

map("i", "<c-f>", "<right>", opt)
map("i", "<c-b>", "<left>", opt)
map("i", "<c-g>", "<esc>", opt)

map("t", "<A-i>", "<C-\\><C-n>", opt)

map("n", "<A-[>", "<c-w><", opt)
map("n", "<A-]>", "<c-w>>", opt)
map("i", "<A-[>", "<c-w><", opt)
map("i", "<A-]>", "<c-w>>", opt)

vim.cmd([[
" see: https://vi.stackexchange.com/questions/2350/how-to-map-alt-key
execute "set <M-j>=\ej"
execute "set <M-k>=\ek"
execute "set <M-h>=\eh"
execute "set <M-l>=\el"

nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-h> <C-w>h
nnoremap <M-l> <C-w>l
]])

map("n", "<leader>q", ":qa!<cr>", opt)

vim.cmd([[command D windo diffthis]])
