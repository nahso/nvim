-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    "folke/tokyonight.nvim",
    "nvim-tree/nvim-web-devicons",

    "kylechui/nvim-surround",
    "phaazon/hop.nvim", -- 's' jump
    "windwp/nvim-autopairs",
    "farmergreg/vim-lastplace",
    "max397574/better-escape.nvim",
    "lewis6991/gitsigns.nvim",
    "tpope/vim-fugitive",
    "Pocco81/auto-save.nvim",
    "ibhagwan/fzf-lua",
    "ojroques/nvim-osc52",
    "LunarVim/bigfile.nvim",
    "wsdjeg/vim-fetch",  -- open and jump to file:line
    "godlygeek/tabular",
    "djoshea/vim-autoread",
    "numToStr/Comment.nvim",
    "wellle/targets.vim", -- text objects
    "folke/which-key.nvim",
    "RRethy/vim-illuminate",

    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint",

    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/nvim-cmp",

    "folke/trouble.nvim",
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
    },
    "nvim-treesitter/nvim-treesitter-context",
    "ludovicchabant/vim-gutentags",
    "Yggdroot/indentLine",
    "NMAC427/guess-indent.nvim",

    "github/copilot.vim",
    {
      "nahso/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    { "nahso/rsync-build.nvim", dir = "~/Git/rsync-build.nvim" }
  },
})

require("tokyonight").setup({
  style = "night",
  styles = {
    comments = { italic = false },
  },
  on_colors = function(colors)
    colors.comment = "#6a9955"
  end,
})
vim.cmd([[
colorscheme tokyonight
highlight StatusLine ctermfg=white ctermbg=24 guifg=#ffffff guibg=#005f87
]])

require("nvim-surround").setup()

require("hop").setup()
vim.api.nvim_command("hi HopNextKey guifg=#00ff00")
vim.api.nvim_command("hi HopNextKey1 guifg=#00ff00")
vim.api.nvim_command("hi HopNextKey2 guifg=#00ff00")
vim.keymap.set("n", "s", require("hop").hint_char2)
vim.keymap.set("v", "s", require("hop").hint_char2)

require("nvim-autopairs").setup()
require("Comment").setup()
require("which-key").setup({
  delay = 2000,
})

require("conform").setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "black", "isort" },
    lua = { "stylua" },
  },
  default_format_opts = {
    async = false,
    quiet = false,
  }
})
vim.keymap.set("n", "<leader>8", function()
  require("conform").format()
end, { desc = "Format buffer" })
vim.keymap.set("v", "<leader>8", function()
  require("conform").format()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end, { desc = "Format selection" })

require("lint").linters_by_ft = {
  python = { "flake8", "mypy" },
}
vim.cmd([[
au BufWritePost * lua require('lint').try_lint()
au BufReadPost * lua require('lint').try_lint()
]])

local cmp_nvim_lsp = require("cmp_nvim_lsp")
require("lspconfig").basedpyright.setup({
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = "basic",
      },
    },
  },
})
require("lspconfig").clangd.setup({
  on_attach = on_attach,
  capabilities = cmp_nvim_lsp.default_capabilities(),
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
    "--background-index",
    "--suggest-missing-includes",
    "-j=8",
    "--enable-config",
  },
})
vim.lsp.set_log_level("off")

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local cmp = require("cmp")
cmp.setup({
  window = {
    documentation = cmp.config.window.bordered(),
    completion = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
  }, {
    { name = "buffer" },
  }),
})

require("trouble").setup({})
require("better_escape").setup {
  default_mappings = false,
  mappings = {
    i = { j = { k = "<Esc>" }}
  }
}

require('gitsigns').setup({
  signs = {
    add          = { text = '+' },
    change       = { text = '=' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '|+' },
    change       = { text = '|=' },
    delete       = { text = '|_' },
    topdelete    = { text = '|‾' },
    changedelete = { text = '|~' },
    untracked    = { text = '|┆' }, 
  },
})
local gitsigns = require('gitsigns')
vim.keymap.set('n', '[h', function()
  if vim.wo.diff then
    vim.cmd.normal({'[h', bang = true})
  else
    gitsigns.nav_hunk('prev')
  end
end, { desc = "Prev hunk" })
vim.keymap.set('n', ']h', function()
  if vim.wo.diff then
    vim.cmd.normal({']h', bang = true})
  else
    gitsigns.nav_hunk('next')
  end
end, { desc = "Next hunk" })
vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set('v', '<leader>hs', function()
  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Stage hunk" })
vim.keymap.set('v', '<leader>hr', function()
  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Reset hunk" })
vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
-- vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

require("auto-save").setup({})

local ts_install = require("nvim-treesitter.install")
ts_install.prefer_git = true
ts_install.compilers = { "gcc", "clang" }
local parsers = require("nvim-treesitter.parsers").get_parser_configs()
for _, p in pairs(parsers) do
  p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
end
local ts_install = require("nvim-treesitter.install")
ts_install.prefer_git = true
ts_install.compilers = { "gcc", "clang" }
local parsers = require("nvim-treesitter.parsers").get_parser_configs()
for _, p in pairs(parsers) do
  p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
end
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "vimdoc",
    "yaml",
    "cuda",
  },
  disable = { "latex" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
require("treesitter-context").setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 10, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 1, -- Maximum number of lines to collapse for a single context line
  trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
})
vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])

local fzf = require("fzf-lua")
fzf.setup({
  winopts = {
    fullscreen = false,
    preview = {
      vertical = "down:30%",
      layout = "vertical",
    },
  },
  commands = {
    actions = {
      ["default"] = require("fzf-lua").actions.ex_run_cr,
      ["ctrl-y"] = require("fzf-lua").actions.ex_run,
    },
  },
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fd", fzf.git_files, { desc = "Fuzzy find git files" })
vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Fuzzy find recent files" })
vim.keymap.set("n", "<leader>rs", fzf.resume, { desc = "Resume last fzf" })
vim.keymap.set("n", "<leader>tt", fzf.tags, { desc = "Fuzzy find all tags" })
vim.keymap.set("n", "<leader>st", fzf.btags, { desc = "Fuzzy find buffer tags" })
vim.keymap.set("n", "<leader>tl", fzf.tags_live_grep, { desc = "Fuzzy find tags live grep" })
vim.keymap.set("n", "<leader>gt", fzf.tags_grep_cword, { desc = "Fuzzy find tags grep cword" })
vim.keymap.set("n", "<leader>bb", fzf.buffers, { desc = "Fuzzy find buffers" })
vim.keymap.set("n", "<leader>er", fzf.lsp_references, { desc = "Fuzzy find references" })
vim.keymap.set("n", "<leader>ed", fzf.lsp_definitions, { desc = "Fuzzy find definitions" })
vim.keymap.set("n", "<leader>eD", fzf.lsp_declarations, { desc = "Fuzzy find declarations" })
vim.keymap.set("n", "<leader>sf", fzf.live_grep, { desc = "Fuzzy find live grep" })
vim.keymap.set("n", "<leader>ss", fzf.grep_project, { desc = "Fuzzy find grep project" })
vim.keymap.set("n", "<leader>sd", fzf.grep_cword, { desc = "Fuzzy find grep cword" })
vim.keymap.set("n", "<leader>sD", fzf.grep_cWORD, { desc = "Fuzzy find grep cWORD" })

vim.keymap.set("n", "<A-x>", fzf.commands)
vim.keymap.set("i", "<A-x>", fzf.commands)
vim.keymap.set("n", "<C-s>", fzf.blines)
vim.keymap.set("i", "<C-s>", fzf.blines)

require("osc52").setup({
  max_length = 0, -- Maximum length of selection (0 for no limit)
  silent = false, -- Disable message on successful copy
  trim = false, -- Trim surrounding whitespaces before copy
})
vim.keymap.set("n", "<A-w>", require("osc52").copy_operator, { expr = true })
vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
vim.keymap.set("v", "<A-w>", require("osc52").copy_visual)

vim.cmd([[
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']
let g:gutentags_ctags_tagfile = '.tags'

let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif

let g:gutentags_ctags_extra_args = ['--fields=+niaz', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--python-kinds=-iv']
let g:gutentags_ctags_extra_args += ['--exclude=*.md --exclude=*.json --exclude=build --exclude=_skbuild']
if filereadable(".gitignore")
    let g:gutentags_ctags_extra_args += ['--exclude=@.gitignore']
endif
if executable('rg')
    let g:gutentags_file_list_command = 'rg --files'
endif
]])

vim.cmd([[
let g:indentLine_enabled = 1
]])
require("guess-indent").setup({})
require("bigfile").setup()

vim.cmd([[
let g:copilot_proxy = getenv('http_proxy')
imap <silent><script><expr> <C-\> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
]])

require("illuminate").configure({
  -- delay = 0,
  under_cursor = false,
})

require("nvim-tree").setup {}

require("rsync-build").setup()
local rb = require("rsync-build")
vim.keymap.set("n", "<leader>l", function()
  rb.upload_dir()
end, { desc = "Send file rsync-build" })
vim.keymap.set("n", "<leader>;", function()
  rb.do_action()
end, { desc = "Send file rsync-build" })
