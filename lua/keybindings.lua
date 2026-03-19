-- 设置 Leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 公共选项 (vim.keymap.set 默认就是 noremap)
local opts = { silent = true }
-- 基础映射 (n: Normal, v: Visual, i: Insert, t: Terminal, c: Command)
local key = vim.keymap.set

-- 禁用不常用的功能
key("n", "q:", "<nop>", opts)
key("n", "s", "<nop>", opts)

-- 常用操作
key("n", "<leader>fs", ":w<cr>", opts)
key("n", "<leader><cr>", ":noh<cr>", opts) -- 清除搜索高亮
key("n", "Y", "y$", opts)                  -- 让 Y 的行为和 D, C 一致

-- 窗口操作
key("n", "<leader>w", "<c-w>", opts)
key("n", "<leader>wd", "<c-w>c", opts)

-- 系统剪贴板 (Visual 模式)
key("v", "<leader>y", '"+y', opts)
key("v", "<leader>p", '"+p', opts)

-- 搜索选中的文本 (//)
key("v", "//", [[y/\V<C-R>=escape(@", '/\')<CR><CR>]], opts)

-- 插入模式下的位移 (类似 Emacs)
key("i", "<c-f>", "<right>", opts)
key("i", "<c-b>", "<left>", opts)
key("i", "<c-g>", "<esc>", opts)

-- 终端模式
key("t", "<A-i>", [[<C-\><C-n>]], opts)
key("t", "<Esc>", [[<C-\><C-n>]], opts) -- 统一 Esc 退出终端模式

-- 调整窗口大小 (Alt + [ / ])
key({ "n", "i" }, "<A-[>", "<cmd>vertical resize -2<cr>", opts)
key({ "n", "i" }, "<A-]>", "<cmd>vertical resize +2<cr>", opts)

-- 窗口跳转 (使用 Alt + hjkl)
-- 0.10+ 版本不再需要 set <M-j> 这种 Hack
key("n", "<M-j>", "<C-w>j", opts)
key("n", "<M-k>", "<C-w>k", opts)
key("n", "<M-h>", "<C-w>h", opts)
key("n", "<M-l>", "<C-w>l", opts)

-- 命令行模式映射 (取代 cnoremap)
key("c", "<C-A>", "<Home>")
key("c", "<C-F>", "<Right>")
key("c", "<C-B>", "<Left>")
key("c", "<Esc>b", "<S-Left>")
key("c", "<Esc>f", "<S-Right>")

-- 强制退出所有窗口并关闭 Neovim
-- key("n", "<leader>q", ":qa!<cr>", opts)

-- 自定义命令
vim.api.nvim_create_user_command("D", "windo diffthis", { desc = "Diff all windows" })
