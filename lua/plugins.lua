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

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    "folke/tokyonight.nvim",
    "Mofiqul/vscode.nvim",
    "EdenEast/nightfox.nvim",
    "miikanissi/modus-themes.nvim",
    "nvim-tree/nvim-web-devicons",
    "stevearc/oil.nvim", -- 以编译buffer的方式操作文件系统

    "kylechui/nvim-surround",
    "folke/flash.nvim", -- 按 s 跳转
    "windwp/nvim-autopairs",
    "farmergreg/vim-lastplace",
    "max397574/better-escape.nvim",
    "lewis6991/gitsigns.nvim",
    "tpope/vim-fugitive",
    "okuuva/auto-save.nvim",
    "ibhagwan/fzf-lua",
    "LunarVim/bigfile.nvim",
    "wsdjeg/vim-fetch",  -- open and jump to file:line
    "godlygeek/tabular",
    "djoshea/vim-autoread",

    "echasnovski/mini.ai", -- text objects
    "folke/which-key.nvim",
    "RRethy/vim-illuminate",
    "rickhowe/spotdiff.vim",

    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint",

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    
    "ojroques/nvim-osc52",
    "folke/trouble.nvim",
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
    },
    "nvim-treesitter/nvim-treesitter-context",
    "ludovicchabant/vim-gutentags",
    "shellRaining/hlchunk.nvim",
    "NMAC427/guess-indent.nvim",

    "zbirenbaum/copilot.lua",
    "lervag/vimtex",
    "stevearc/aerial.nvim",

    "nvim-lua/plenary.nvim",
  },
})

-- ==========================================
-- UI & Theme 配置
-- ==========================================
vim.o.background = 'dark'
require('vscode').setup({
  -- Alternatively set style in setup
  -- style = 'light'
  transparent = false,

  -- Enable italic comment
  italic_comments = false,

  -- Enable italic inlay type hints
  italic_inlayhints = true,

  -- Underline `@markup.link.*` variants
  underline_links = true,

  -- Disable nvim-tree background color
  disable_nvimtree_bg = true,

  -- Apply theme colors to terminal
  terminal_colors = true,

  group_overrides = {
    CursorLine = { bg = '#333333' },

    -- 1. 非当前匹配项：不那么亮眼的橙色（使用更深的橙色以减少亮度，但保持显眼）
    Search = { 
      fg = '#ffffff', 
      bg = '#daa520',
      bold = true,
    },
    
    -- 2. 当前匹配项：保持亮绿色以提供对比
    IncSearch = { 
      fg = '#000000',     -- 黑色文字
      bg = '#7cfc00',     -- 草绿色/亮绿色背景
      bold = true,
    },

    -- 3. 确保新版 Neovim 的 CurSearch 也同步（直接链接到 IncSearch）
    CurSearch = { link = 'IncSearch' },
    StatusLine = { fg = '#ffffff', bg = '#007acc', bold = true },
    -- 不活动状态栏：使用暗蓝色背景，保持白色文字，但不加粗以区分
    StatusLineNC = { fg = '#ffffff', bg = '#004080', bold = false },
    -- Diff视图中删除的文本：使用不显眼的红色背景
    DiffDelete = { bg = '#b22222', fg = '#ffffff', bold = true },
    -- 修改的行：使用更不显眼的红色背景，比DiffText暗一些
    DiffChange = { bg = '#8b0000', fg = '#ffffff' },
    -- 修改行中具体改变的部分：保持亮红色以突出，不能比这个更暗
    DiffText = { bg = '#ff0000', fg = '#ffffff', bold = true },
    -- Diff视图中新增的行：使用不显眼的绿色背景，与红色显眼程度一致
    DiffAdd = { bg = '#006400', fg = '#ffffff' },

    -- Flash: 待跳转字符 (Label) 颜色，使用洋红高亮，与搜索的橙/绿明确区分
    FlashLabel = { bg = '#ff00ff', fg = '#ffffff', bold = true },
    -- Flash: 输入停顿时已匹配的背景文本颜色，使用深灰降低视觉干扰
    FlashMatch = { bg = '#555555', fg = '#ffffff' },
    -- Flash: 当前光标所在匹配项
    FlashCurrent = { link = 'IncSearch' },
  },
})
vim.cmd.colorscheme "vscode"

-- ==========================================
-- 核心操作类插件配置
-- ==========================================
require("nvim-surround").setup()
require("oil").setup({
  float = {
    padding = 2,
    max_width = 0,
    max_height = 0,
    border = "rounded", -- 改动点 1：浮动主窗口边框
    win_options = {
      winblend = 0,
    },
    -- ...
  },
  -- ...
  confirmation = {
    -- ...
    border = "rounded", -- 改动点 2：操作确认对话框边框
    win_options = {
      winblend = 0,
    },
  },
  progress = {
    -- ...
    border = "rounded", -- 改动点 3：进度条窗口边框
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
  ssh = {
    border = "rounded", -- 改动点 4：SSH 相关弹窗边框
  },
  keymaps_help = {
    border = "rounded", -- 改动点 5：快捷键帮助窗口边框
  },
})

-- Flash.nvim 配置
require("flash").setup({
  -- 全局默认标签（根据你的需求自定义顺序）
  labels = "asdfghjklqwertyuiopzxcvbnm",
  highlight = {
    -- 默认关闭全局背景遮罩（影响 s 键跳转）
    backdrop = false,
  },
  modes = {
    -- 针对 f, F, t, T, ;, , 运动的特定设置
    char = {
      enabled = true,
      -- 1. 禁用跨行匹配，仅限当前行
      multi_line = false,
      -- 2. 核心修改：显式禁用字符查找模式下的背景变暗效果
      highlight = { 
        backdrop = false 
      },
      -- 保持你的默认键位行为
      jump_labels = false,
    },
  },
})
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })

require("mini.ai").setup()

require("hlchunk").setup({
  indent = {
    enable = true
  }
})

require("nvim-autopairs").setup()
require("which-key").setup({
  delay = 2000,
})

-- ==========================================
-- 格式化与 Lint (使用 Ruff)
-- ==========================================
require("conform").setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "ruff_format", "ruff_fix" },
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
}
vim.cmd([[
au BufWritePost * lua require('lint').try_lint()
au BufReadPost * lua require('lint').try_lint()
]])

-- ==========================================
-- LSP & Mason 配置
-- ==========================================
local function ensure_ts_cli()
  -- 1. 检查系统 PATH 或 Mason 路径下是否已存在二进制
  if vim.fn.executable("tree-sitter") == 1 then
    return
  end

  -- 2. 检查 Mason 是否可用
  local ok, mr = pcall(require, "mason-registry")
  if not ok then
    vim.notify("mason-registry not found", vim.log.levels.WARN)
    return
  end

  -- 3. 获取并安装工具
  local package_name = "tree-sitter-cli"
  
  -- 确保在注册表刷新后操作（异步安装流程）
  mr.refresh(function()
    local p = mr.get_package(package_name)
    if not p:is_installed() then
      vim.notify("Installing tree-sitter-cli via Mason...", vim.log.levels.INFO)
      p:install():once("terminate", function(success)
        if success then
          vim.notify("tree-sitter-cli installed successfully.", vim.log.levels.INFO)
          -- 安装成功后，手动将 Mason 的 bin 目录临时加入 PATH 供当前进程使用
          local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
          vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
        else
          vim.notify("Failed to install tree-sitter-cli.", vim.log.levels.ERROR)
        end
      end)
    end
  end)
end

require("mason").setup()
ensure_ts_cli()

require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright", "ruff", "texlab" }
})

local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

require("mason-lspconfig").setup({
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
    })
  end,
  ["clangd"] = function()
    require("lspconfig").clangd.setup({
      capabilities = capabilities,
      cmd = {
        "clangd",
        "--offset-encoding=utf-16",
        "--background-index",
        "--suggest-missing-includes",
        "-j=8",
        "--enable-config",
      },
    })
  end,
})
vim.lsp.set_log_level("off")

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- ==========================================
-- 代码大纲 Aerial
-- ==========================================
require("aerial").setup({
  layout = { max_width = { 40, 0.2 }, min_width = 20 },
})
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial Outline" })

-- ==========================================
-- 补全引擎 (集成 LuaSnip)
-- ==========================================
local luasnip = require("luasnip")
local cmp = require("cmp")

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded', -- 可选 'single', 'double', 'shadow', 'rounded'
      winhighlight = 'Normal:CmpPmenu,CursorLine:PmenuSel,Search:None',
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:CmpDoc,Search:None',
    }),
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

-- ==========================================
-- 杂项工具与辅助
-- ==========================================
require("trouble").setup({})
require("better_escape").setup {
  default_mappings = false,
  mappings = {
    i = { j = { k = "<Esc>" }},
    t = { j = { k = "<C-\\><C-n>" }}
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

require("auto-save").setup({
  debounce_delay = 50
})

-- Treesitter
local ts_install = require("nvim-treesitter.install")
ts_install.prefer_git = true
require("nvim-treesitter.config").setup({
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

-- FZF
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
let g:gutentags_ctags_executable = '/opt/homebrew/bin/ctags'
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

vim.g.vimtex_view_method = 'general'
vim.g.vimtex_compiler_method = 'latexmk'

require("guess-indent").setup({})
require("bigfile").setup()

require("illuminate").configure({
  -- delay = 0,
  under_cursor = false,
})

require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-\\>",
      accept_word = false,
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    markdown = true,
    help = false,
    gitcommit = false,
  },
})
