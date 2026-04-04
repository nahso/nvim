-- ==========================================================================
-- 视图与界面渲染 (UI & Display)
-- ==========================================================================

-- 显示行号
vim.opt.number = true
-- 显示相对行号
vim.opt.relativenumber = true
-- 高亮当前光标所在行
vim.opt.cursorline = true
-- 启用真彩色支持
vim.opt.termguicolors = true
-- 设置深色背景主题
vim.opt.background = "dark"
-- 不显示模式信息（如 -- INSERT --）
vim.opt.showmode = false
-- 补全弹出菜单的最大高度为 10 行
vim.opt.pumheight = 10

-- 垂直滚动偏移：光标距离屏幕顶部或底部 5 行时自动滚动
vim.opt.scrolloff = 5
-- 水平滚动偏移：光标距离屏幕左侧或右侧 5 个字符时自动滚动
vim.opt.sidescrolloff = 5

-- ==========================================================================
-- 缩进与排版 (Indent & Formatting)
-- ==========================================================================

-- 1 个 Tab 字符在屏幕上显示的宽度
vim.opt.tabstop = 4
-- 编辑模式下按 Tab 或 Backspace 时视作的空格数
vim.opt.softtabstop = 4
-- 每一级自动缩进所使用的空格数
vim.opt.shiftwidth = 4
-- 将 Tab 键自动转换为空格
vim.opt.expandtab = true
-- 缩进时自动对齐到 shiftwidth 的整数倍
vim.opt.shiftround = true
-- 开启针对类 C 语言风格的智能缩进
vim.opt.smartindent = true
-- 默认关闭自动折行
vim.opt.wrap = false

-- 是否进入“列表模式”显示不可见字符
vim.opt.list = false
-- 定义不可见字符的显示样式，这里设置行尾多余空格显示为 ·
vim.opt.listchars = { trail = "·" }

-- ==========================================================================
-- 搜索与匹配 (Search)
-- ==========================================================================

-- 搜索时忽略大小写
vim.opt.ignorecase = true
-- 若搜索词包含大写字母，则自动转为大小写敏感匹配
vim.opt.smartcase = true
-- 在命令行输入命令并按 Tab 键时，在状态栏上方显示一个水平的候选列表
vim.opt.wildmenu = true

-- ==========================================================================
-- 系统行为与性能 (System & Performance)
-- ==========================================================================

-- 在用户停止输入后，经过多少毫秒（ms）认为编辑器处于“空闲（Idle）”状态
vim.opt.updatetime = 300
-- 允许在未保存修改的情况下切换 Buffer
vim.opt.hidden = true
-- 新水平拆分窗口出现在当前窗口下方
vim.opt.splitbelow = true
-- 新垂直拆分窗口出现在当前窗口右侧
vim.opt.splitright = true
-- 不显示类似 "Match 1 of 20" 或 "Pattern not found" 的提示
vim.opt.shortmess:append("c")

-- 禁用备份文件
vim.opt.backup = false
-- 禁用写备份
vim.opt.writebackup = false
-- 禁止创建 .swap 文件
vim.opt.swapfile = false

-- 增强退格键功能，允许删掉缩进、行尾换行符及起始字符
vim.opt.backspace = "indent,eol,start"

-- 补全弹出框行为：显示菜单、单个候选也显、不默认选中、不自动插入
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }

-- ==========================================================================
-- 自动命令：针对特定文件类型的差异化配置 (Autocmds)
-- ==========================================================================

local group = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

-- 为 Lua, C, C++ 文件设置 2 空格缩进
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Set 2-space indent for lua, c, cpp",
})

-- 为 Markdown 和 LaTeX 开启自动折行，并优化折行后的光标移动逻辑
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "tex" },
  callback = function(args)
    local opts = { 
      silent = true, 
      buffer = args.buf, 
      expr = true, 
      replace_keycodes = true -- 确保返回的字符被正确解析
    }

    -- 1. 处理 j/k 的动态逻辑 (使用 expr 模式)
    vim.keymap.set('n', 'j', function()
      return vim.v.count == 0 and 'gj' or 'j'
    end, opts)

    vim.keymap.set('n', 'k', function()
      return vim.v.count == 0 and 'gk' or 'k'
    end, opts)

    -- 2. 处理 0/^ 的逻辑
    -- 注意：由于 opts 开启了 expr，这里的映射目标需要写成字符串表达式（带引号）
    vim.keymap.set('n', '0', [['g0']], opts)
    vim.keymap.set('n', '^', [['g^']], opts)

    vim.opt_local.wrap = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
  desc = "Apply wrap and visual line movement keys for Markdown and Tex files",
})

-- 修复 Python 下注释对齐问题
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function()
    -- 允许 << 和 >> 缩进 # 开头的注释行
    -- '0#' 表示如果输入 # 则不跳转到行首
    vim.opt_local.indentkeys:remove("0#")
    -- 有时 nosmartindent 也会影响，确保它在 python 中是关闭的或调整其行为
    vim.opt_local.smartindent = false
  end,
  desc = "Fix python comment indentation for << and >>",
})

-- 自定义statusline
local modes = {
  ['n']  = 'NORMAL',
  ['i']  = 'INSERT',
  ['v']  = 'VISUAL',
  ['V']  = 'V-LINE',
  [''] = 'V-BLOCK',
  ['c']  = 'COMMAND',
  ['R']  = 'REPLACE',
  ['t']  = 'INSERT',
  ['nt'] = 'NORMAL',
}
function _G.my_statusline()
  local m = vim.api.nvim_get_mode().mode
  local mode_str = string.format("[%s] ", modes[m] or m)
  
  -- 组合字符串：
  -- %f: 文件名  %m: 修改标记  %=: 左右分割  %l,%c: 行,列  %P: 百分比
  return mode_str .. "%f %m%=%l,%c %P "
end
vim.opt.statusline = "%!v:lua.my_statusline()"

-- 强制终端在进入时停留在 Normal 模式
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    pattern = "term://*",
    callback = function()
        -- 延迟一小会儿执行，确保在插件逻辑之后运行
        vim.schedule(function()
            vim.cmd("stopinsert")
        end)
    end,
})
