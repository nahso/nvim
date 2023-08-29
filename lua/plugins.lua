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

        use({
            "L3MON4D3/LuaSnip",
            -- install jsregexp (optional!:).
            run = "make install_jsregexp"
        })

        use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
        use({
            "nvim-treesitter/nvim-treesitter-textobjects",
            after = "nvim-treesitter",
            requires = "nvim-treesitter/nvim-treesitter",
        })
        use 'nvim-treesitter/nvim-treesitter-context'
        use 'wellle/targets.vim'

        use 'nvim-tree/nvim-web-devicons'
        use 'ibhagwan/fzf-lua'
        use 'ojroques/nvim-osc52'
        use 'Pocco81/auto-save.nvim'
        use 'airblade/vim-gitgutter'
        use {
            'NeogitOrg/neogit',
            requires = {
                'nvim-lua/plenary.nvim',
                'sindrets/diffview.nvim'
            }
        }
        -- use 'preservim/nerdcommenter'
        use {
            'numToStr/Comment.nvim',
            config = function()
                require('Comment').setup()
            end
        }
        use 'ludovicchabant/vim-gutentags'
        use 'djoshea/vim-autoread'
        use "lukas-reineke/indent-blankline.nvim"
        use "NMAC427/guess-indent.nvim"

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

        use 'RRethy/vim-illuminate'

        use 'github/copilot.vim'

        use 'lambdalisue/suda.vim'

        use {
            "klen/nvim-config-local",
            config = function()
                require('config-local').setup {
                    -- Default options (optional)

                    -- Config file patterns to load (lua supported)
                    config_files = { ".nvim.lua", ".nvimrc", ".exrc" },

                    -- Where the plugin keeps files data
                    hashfile = vim.fn.stdpath("data") .. "/config-local",

                    autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
                    commands_create = true,     -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
                    silent = false,             -- Disable plugin messages (Config loaded/ignored)
                    lookup_parents = false,     -- Lookup config files in parent directories
                }
            end
        }
    end
})


vim.cmd([[colorscheme tokyonight]])
-- vim.cmd([[colorscheme doom-one]])

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

local cmp_nvim_lsp = require "cmp_nvim_lsp"
require("lspconfig").clangd.setup {
    on_attach = on_attach,
    capabilities = cmp_nvim_lsp.default_capabilities(),
    cmd = {
        "clangd",
        "--offset-encoding=utf-16",
    },
}

-- vim.keymap.set("n", "<leader>ed", vim.lsp.buf.definition)
-- vim.keymap.set("n", "<leader>er", vim.lsp.buf.references) -- use fzf version instead
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
local cmp = require'cmp'
cmp.setup({
    window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        -- ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

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
            },
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
            },
        },
    },
}

local fzf = require('fzf-lua')
fzf.setup{
    winopts = {
        fullscreen = true,
        preview = {
            vertical = 'down:30%',
            layout = 'vertical'
        },
    }
}

vim.keymap.set('n', '<leader>ff', fzf.files)
vim.keymap.set('n', '<leader>fd', fzf.git_files)
vim.keymap.set('n', '<leader>fr', fzf.oldfiles)
vim.keymap.set('n', '<leader>rs', fzf.resume)
vim.keymap.set('n', '<leader>tt', fzf.tags)
vim.keymap.set('n', '<leader>tb', fzf.btags)
vim.keymap.set('n', '<leader>tl', fzf.tags_live_grep)
vim.keymap.set('n', '<leader>bt', fzf.tags_grep_cword)
vim.keymap.set('n', '<leader>bb', fzf.buffers)
vim.keymap.set('n', '<leader>er', fzf.lsp_references)
vim.keymap.set('n', '<leader>sf', fzf.live_grep)
vim.keymap.set('n', '<leader>ss', fzf.grep_project)
vim.keymap.set('n', '<leader>sd', fzf.grep_cword)
vim.keymap.set('n', '<leader>sD', fzf.grep_cWORD)

vim.keymap.set('n', '<A-x>', fzf.commands)
vim.keymap.set('i', '<A-x>', fzf.commands)
vim.keymap.set('n', '<C-s>', fzf.blines)
vim.keymap.set('i', '<C-s>', fzf.blines)

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
vim.cmd([[command U GitGutterUndoHunk]])

require('neogit').setup{}

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
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
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

vim.cmd([[
let g:copilot_proxy = getenv('http_proxy')
imap <silent><script><expr> <C-\> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
]])

-- default configuration
require('illuminate').configure({
    -- delay = 0,
})

