-- ~/.local/share/nvim/site/pack/packer/
local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true }

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local paccker_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
    vim.notify("installing packer.nvim")
    paccker_bootstrap = fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        -- "https://gitcode.net/mirrors/wbthomason/packer.nvim",
        install_path,
    })

    -- https://github.com/wbthomason/packer.nvim/issues/750
    local rtp_addition = vim.fn.stdpath("data") .. "/site/pack/*/start/*"
    if not string.find(vim.o.runtimepath, rtp_addition) then
        vim.o.runtimepath = rtp_addition .. "," .. vim.o.runtimepath
    end
    vim.notify("finished.")
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    vim.notify("can't find packer.nvim, aborted")
    return
end

packer.startup({
    function(use)
        use "wbthomason/packer.nvim"
        use "folke/tokyonight.nvim"
        use 'NTBBloodbath/doom-one.nvim'

        use "kylechui/nvim-surround"
        use "phaazon/hop.nvim"
        use "windwp/nvim-autopairs"
        use "ethanholz/nvim-lastplace"
        use "neovim/nvim-lspconfig"

        use 'hrsh7th/cmp-nvim-lsp'
        use 'hrsh7th/cmp-buffer'
        use 'hrsh7th/nvim-cmp'

        use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
        use({
            "nvim-treesitter/nvim-treesitter-textobjects",
            after = "nvim-treesitter",
            requires = "nvim-treesitter/nvim-treesitter",
        })
        use 'nvim-treesitter/nvim-treesitter-context'

        use 'nvim-tree/nvim-web-devicons'
        use 'ibhagwan/fzf-lua'
        use 'ojroques/nvim-osc52'
        use 'Pocco81/auto-save.nvim'
        use 'airblade/vim-gitgutter'
        use 'preservim/nerdcommenter'
        use 'ludovicchabant/vim-gutentags'
        use 'djoshea/vim-autoread'
        use "lukas-reineke/indent-blankline.nvim"
        use "NMAC427/guess-indent.nvim"

        use {
            'goolord/alpha-nvim',
            requires = { 'nvim-tree/nvim-web-devicons' },
            config = function ()
                require'alpha'.setup(require'alpha.themes.startify'.config)
            end
        }

        use {
            'nvim-tree/nvim-tree.lua',
            requires = {
                'nvim-tree/nvim-web-devicons', -- optional
            },
            config = function()
                require("nvim-tree").setup {}
            end
        }

        use {
            'stevearc/aerial.nvim',
            config = function() require('aerial').setup() end
        }
    end
})


vim.cmd([[colorscheme doom-one]])

require('nvim-surround').setup()

require('hop').setup()
vim.api.nvim_command('hi HopNextKey guifg=#00ff00')
vim.api.nvim_command('hi HopNextKey1 guifg=#00ff00')
vim.api.nvim_command('hi HopNextKey2 guifg=#00ff00')
vim.keymap.set("n", "s", require'hop'.hint_char2)
vim.keymap.set("v", "s", require'hop'.hint_char2)

require("nvim-autopairs").setup()

require('nvim-lastplace').setup({
    lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
    lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
    lastplace_open_folds = true
})

require'lspconfig'.pyright.setup{}
require'lspconfig'.clangd.setup{}

vim.keymap.set("n", "<leader>ed", vim.lsp.buf.definition)
-- vim.keymap.set("n", "<leader>er", vim.lsp.buf.references) -- use fzf version instead
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

local cmp = require'cmp'
cmp.setup({
    window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }, {
        { name = 'buffer' },
    })
})

require("nvim-treesitter.install").prefer_git = true
require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "help", "query" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    textobjects = {
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
            },
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
            },
        },
    },
}

require('fzf-lua').setup{}
vim.keymap.set('n', '<leader>fr', require('fzf-lua').oldfiles)
vim.keymap.set('n', '<leader>bb', require('fzf-lua').buffers)
vim.keymap.set('n', '<leader>ff', require('fzf-lua').files)
vim.keymap.set('n', '<leader>fg', require('fzf-lua').git_files)
vim.keymap.set('n', '<leader>fl', require('fzf-lua').blines)
vim.keymap.set('n', '<leader>er', require('fzf-lua').lsp_references)
vim.keymap.set('n', '<leader>f]', require('fzf-lua').tags_grep_cword)
vim.keymap.set('n', '<leader>t', require('fzf-lua').btags)

require('osc52').setup {
    max_length = 0,      -- Maximum length of selection (0 for no limit)
    silent     = false,  -- Disable message on successful copy
    trim       = false,  -- Trim surrounding whitespaces before copy
}
vim.keymap.set('n', '<A-w>', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<A-w>', require('osc52').copy_visual)

require'auto-save'.setup{}

map('n', ']h', '<Plug>(GitGutterNextHunk)', opt)
map('n', '[h', '<Plug>(GitGutterPrevHunk)', opt)

vim.cmd([[
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']
let g:gutentags_ctags_tagfile = '.tags'

let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif

let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--exclude=*.md']
if filereadable("filename")
    let g:gutentags_ctags_extra_args += ['--exclude=@.gitignore']
endif
if executable('rg')
  let g:gutentags_file_list_command = 'rg --files'
endif
]])

require("indent_blankline").setup {}

require('guess-indent').setup {}

require('aerial').setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
  end
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>')

require'treesitter-context'.setup{
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
    zindex = 20, -- The Z-index of the context window
}
vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
