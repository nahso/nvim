vim.g.encoding = "UTF-8"
vim.o.fileencoding = "utf-8"

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

--vim.o.timeoutlen = 200
--vim.o.timeout = false
--vim.o.ttimeout = false

vim.o.splitbelow = true
vim.o.splitright = true

vim.g.completeopt = "menu,menuone,noselect,noinsert"

vim.o.background = "dark"
vim.o.termguicolors = true
vim.opt.termguicolors = true
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

vim.o.wildmenu = true

vim.o.shortmess = vim.o.shortmess .. "c"

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

vim.cmd([[
set cino+=g0,N-s
" Don't indent template
function! CppNoTemplateIndent()
  let l:cline_num = line('.')
  let l:cline = getline(l:cline_num)
  let l:pline_num = prevnonblank(l:cline_num - 1)
  let l:pline = getline(l:pline_num)

  " Skip comment lines and lone braces
  while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
    let l:pline_num = prevnonblank(l:pline_num - 1)
    let l:pline = getline(l:pline_num)
  endwhile

  " Template indentation rule
  let l:retv = cindent('.')
  let l:pindent = indent(l:pline_num)
  let l:is_template_rule = 0
  " previous line only has a `template`
  if l:pline =~# '^\s*template\s*\s*$' " 
    let l:retv = l:pindent + &shiftwidth
    let l:is_template_rule = 1
  " previous line has a `typename` and ends with a comma
  elseif l:pline =~# '\s*typename\s*.*,\s*$' 
    let l:retv = l:pindent + &shiftwidth
    let l:is_template_rule = 1
  " current line has only a `>`
  elseif l:cline =~# '^\s*>\s*$'
    let l:retv = l:pindent + &shiftwidth
    let l:is_template_rule = 1
  elseif l:pline =~# '\s*typename\s*.*>\s*$'
    let l:retv = l:pindent
    let l:is_template_rule = 1
  endif

  if !l:is_template_rule
  endif

  return l:retv
endfunction

if has("autocmd")
  autocmd BufEnter *.{cc,cxx,cpp,h,hh,hpp,hxx} setlocal indentexpr=CppNoTemplateIndent()
endif
]])

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"lua", "c", "cpp"},
  callback = function(args)
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Set 2-space indent for lua, c, cpp",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown", "tex"},
  callback = function(args)
    vim.opt_local.wrap = true

    local opts = { silent = true, buffer = args.buf, }
    vim.keymap.set('n', 'j', 'gj', opts)
    vim.keymap.set('n', 'k', 'gk', opts)
    vim.keymap.set('n', '0', 'g0', opts)
    vim.keymap.set('n', '^', 'g^', opts)

    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Apply wrap and visual line movement keys for Markdown and Tex files",
})
