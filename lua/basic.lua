vim.g.encoding = "UTF-8"
vim.o.fileencoding = 'utf-8'

vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.cursorline = true

vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4
vim.o.expandtab = true
vim.bo.expandtab = true

vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.incsearch = true

vim.o.autoread = true
vim.bo.autoread = true

vim.wo.wrap = false

vim.o.hidden = true

vim.o.mouse = "a"

vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

vim.o.updatetime = 300

-- vim.o.timeoutlen = 500
vim.o.timeout = false
vim.o.ttimeout = false

vim.o.splitbelow = true
vim.o.splitright = true

vim.g.completeopt = "menu,menuone,noselect,noinsert"

vim.o.background = "dark"
vim.o.termguicolors = true
vim.opt.termguicolors = true

vim.o.wildmenu = true

vim.o.shortmess = vim.o.shortmess .. 'c'

vim.o.pumheight = 10

vim.o.showmode = false

vim.opt.backspace = "indent,eol,start"

vim.o.list = false
vim.o.listchars = "trail:·"

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
