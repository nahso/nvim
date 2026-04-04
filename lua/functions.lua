local projects = {
    {
        local_root  = "/Users/dym/Git/shenchao-MatRIS/MatRIS",
        remote_root = "/home/share/duyiming/MatRIS",
        ssh_host    = "shenchao_tjmp" 
    },
    {
        local_root  = "/Users/dym/Git/hbm_lib_dev",
        remote_root = "/home/dym/code/gb2026/7.shenchao-hbm_lib",
        ssh_host    = "desktop" 
    },
    -- {
    --     local_root  = "/Users/dym/Git/hbm_lib_dev",
    --     remote_root = "/home/share/duyiming/hbm_lib_dev",
    --     ssh_host    = "shenchao" 
    -- },
    -- {
    --     local_root  = "/Users/dym/Git/hbm_lib_dev",
    --     remote_root = "/home/share/guozhuoqiang/duyiming/hbm_lib_dev",
    --     ssh_host    = "shenchao_gzq" 
    -- },
}

local function open_remote_ssh_term(opts)
    local debug_mode = false
    local function debug_log(msg, level)
        if debug_mode then
            vim.notify(msg, level or vim.log.levels.INFO)
        end
    end

    local current_file_dir = vim.fn.expand('%:p:h')
    if current_file_dir == "" then current_file_dir = vim.fn.getcwd() end

    local matched_project = nil
    for _, project in ipairs(projects) do
        if current_file_dir:find(project.local_root, 1, true) == 1 then
            matched_project = project
            break
        end
    end

    if not matched_project then
        print("Error: No mapping found for " .. current_file_dir)
        return
    end

    local relative_offset = current_file_dir:sub(#matched_project.local_root + 1)
    local target_remote_dir = matched_project.remote_root .. relative_offset

    local ssh_cmd = {
        "env",
        "-u", "http_proxy", "-u", "https_proxy", "-u", "all_proxy",
        "-u", "HTTP_PROXY", "-u", "HTTPS_PROXY", "-u", "ALL_PROXY",
        "ssh", "-t", matched_project.ssh_host,
        string.format("cd %q && exec $SHELL", target_remote_dir)
    }

    -- 跨平台桌面系统通知实现
    local function trigger_notification(duration)
        local msg = string.format("Remote command finished in %ds", duration)
        local os_name = (vim.uv or vim.loop).os_uname().sysname

        if os_name == "Darwin" then
            -- macOS: 使用 osascript 调用系统级通知和提示音
            local notify_cmd = string.format([[osascript -e 'display notification "%s" with title "Neovim SSH"' & afplay -v 30 /System/Library/Sounds/Ping.aiff &]], msg)
            os.execute(notify_cmd)
        elseif os_name == "Linux" then
            -- Linux: 使用 notify-send 并附加基于 paplay 或 terminal bell 的声音支持
            os.execute(string.format("notify-send \"Neovim SSH\" \"%s\" -u normal &", msg))
            os.execute("paplay /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1 &")
        elseif os_name == "Windows_NT" then
            -- Windows: PowerShell 原生通知提示音
            local script = string.format([[powershell -Command "Add-Type -AssemblyName PresentationCore; [System.Media.SystemSounds]::Beep.Play();" &]])
            os.execute(script)
        end
    end

    -- 状态捕获闭包变量
    local cmd_start_time = nil
    local in_tui_mode = false -- 新增：备用屏幕缓冲区状态机标识
    local long_cmd_threshold = 5 -- 长命令判定阈值（秒），可依需修改

    local term_opts = {
        on_stdout = function(_, data, _)
            if not data then return end

            -- 将当前数据块拼接，拦截并解析备用屏幕缓冲区切换指令
            local chunk = table.concat(data, "\n")

            -- 检测进入备用屏幕缓冲区 (如启动 Vim, htop, less)
            if chunk:find('\27%[%?1049h') or chunk:find('\27%[%?47h') then
                in_tui_mode = true
                cmd_start_time = nil -- 丢弃当前计时，避免累计
                debug_log("[TUI Mode] 进入备用屏幕缓冲区", vim.log.levels.INFO)
            end

            -- 检测退出备用屏幕缓冲区 (如退出 Vim)
            if chunk:find('\27%[%?1049l') or chunk:find('\27%[%?47l') then
                in_tui_mode = false
                cmd_start_time = nil -- 重置计时器，防止紧接着出现的 PS1 触发误报
                debug_log("[TUI Mode] 退出备用屏幕缓冲区", vim.log.levels.INFO)
            end

            -- 处于 TUI 模式时，挂起一切提示符匹配逻辑
            if in_tui_mode then return end

            -- 获取 stdout 数据流最后一个有效片段
            local last_line = data[#data]
            if last_line == "" and #data > 1 then
                last_line = data[#data-1]
            end

            if not last_line or last_line == "" then return end

            -- 剔除 CSI (Control Sequence Introducer) 和 OSC (Operating System Command) 的 ANSI 转移序列
            local clean_line = last_line:gsub('\x1b%[[%d;]*[a-zA-Z]', ''):gsub('\x1b%].-\x07', '')

            -- 验证终端提示符 (支持常规 Bash/Zsh/Fish: 以 $, #, % 结尾)
            local is_prompt = clean_line:match("[%#%$%%]%s.*$") ~= nil

            if is_prompt then
                -- 检测到提示符，计算执行时间差
                if cmd_start_time then
                    local duration = os.time() - cmd_start_time
                    debug_log("[Prompt] 输出含提示符。距上次敲击回车耗时: " .. duration .. "s", vim.log.levels.DEBUG)
                    
                    if duration >= long_cmd_threshold then
                        debug_log("[ALERT] 长命令执行完毕！耗时: " .. duration .. "s", vim.log.levels.WARN)
                        if trigger_notification then trigger_notification(duration) end
                    end
                    cmd_start_time = nil
                end
            else
                -- 未检测到提示符，视为有进程执行或键盘输入
                -- 【已移除】：原有的依靠换行符隔离键盘单字回显与回车执行的猜测逻辑
                -- （该处已被下方更严谨的 <CR> 键盘映射所取代）
            end
        end
    }

    -- 创建窗口并打开终端
    vim.cmd("botright 15new") 
    -- vim.fn.termopen(ssh_cmd, term_opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local job_id = vim.fn.termopen(ssh_cmd, term_opts)

    vim.bo[bufnr].bufhidden = 'hide'  -- 防止 Buffer 隐藏时自动删除
    vim.bo[bufnr].buflisted = true    -- 确保在 :ls 中可见
    vim.bo[bufnr].modified = false    -- 标记为未修改，防止退出时询问

    -- 设置一些终端窗口的常用属性
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    -- 4. 如果传了参数，则设置 Buffer 名字
    -- opts.args 是用户输入的字符串
    if opts.args and opts.args ~= "" then
        vim.cmd("file " .. opts.args)
    end

    -- 提取出的统一回车/执行逻辑处理函数
    local function on_terminal_enter()
        -- 1. 无论何种情况，必须先将真实的回车符发送给 PTY 进程，保证终端正常交互
        -- 注意：对于 C-j，在大多数 shell 中发送 \n 即可触发执行
        vim.fn.chansend(job_id, "\r")

        -- 2. 如果在 TUI 内 (如在 SSH 中用 nvim)，完全忽略
        if in_tui_mode then return end

        -- 3. 获取 Buffer 内容，并解决 "新终端下方全是空白行" 导致抓取不到内容的痛点
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local last_content_line = ""
        for i = #lines, 1, -1 do
            if lines[i] and lines[i]:match("%S") then -- 倒序找到最近的一行包含非空字符的行
                last_content_line = lines[i]
                break
            end
        end

        -- 4. 剔除 ANSI 转移序列以供验证
        local clean_line = last_content_line:gsub('\x1b%[[%d;]*[a-zA-Z]', ''):gsub('\x1b%].-\x07', '')
        
        -- 5. 判断当前按下回车时，光标所在处是否是 Prompt
        local is_prompt = clean_line:match("[%#%$%%]%s.*$") ~= nil

        if is_prompt then
            -- 如果是在提示符后按下的回车，无论它是执行命令还是 zsh 补全确定菜单，都打上时间戳
            cmd_start_time = os.time()
            debug_log("[Execute] 在提示符处触发执行，开始计时!", vim.log.levels.INFO)
        else
            debug_log("[Execute] 当前不在提示符行，忽略执行事件 (内容: " .. clean_line .. ")", vim.log.levels.DEBUG)
        end
    end

    -- 新增：通过拦截终端模式的回车键 (<CR>) 和 Ctrl-j (<C-j>) 来精准判断命令发送时机
    vim.keymap.set('t', '<CR>', on_terminal_enter, { buffer = bufnr })
    vim.keymap.set('t', '<C-j>', on_terminal_enter, { buffer = bufnr })
end

-- 注册命令，nargs = '?' 表示参数是可选的 (0个或1个)
vim.api.nvim_create_user_command('RemoteTerm', open_remote_ssh_term, {
    nargs = '?',
    desc = 'Open SSH terminal with optional buffer name'
})

-- 用法: :SetRemoteConfig <Host> <RemoteRoot>
-- 示例: :SetRemoteConfig backup-server /home/data/dym/MatRIS
vim.api.nvim_create_user_command('SetRemoteConfig', function(cmd_opts)
    -- 使用 f-args 获取空格分隔的参数列表
    local args = cmd_opts.fargs
    if #args < 2 then
        print("Usage: :SetRemoteConfig <hostname> <remote_root>")
        return
    end

    local new_host = args[1]
    local new_remote_root = args[2]

    local current_file_dir = vim.fn.expand('%:p:h')
    if current_file_dir == "" then current_file_dir = vim.fn.getcwd() end

    local found = false
    for _, project in ipairs(projects) do
        if current_file_dir:find(project.local_root, 1, true) == 1 then
            project.ssh_host = new_host
            project.remote_root = new_remote_root
            found = true
            print(string.format("Updated [%s]\nHost: %s\nRemoteRoot: %s", project.local_root, new_host, new_remote_root))
        end
    end

    if not found then
        print("Error: Current directory is not within any defined local_root.")
    end
end, {
    nargs = '+',
    desc = 'Update both ssh_host and remote_root for the current project'
})

local function cleanup_exited_terminals()
    local bufs = vim.api.nvim_list_bufs()
    local closed_count = 0

    for _, bufnr in ipairs(bufs) do
        -- 确认该 buffer 是有效终端
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == 'terminal' then
            -- 获取终端对应的 job_id
            local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

            if success and job_id then
                -- jobwait({id}, timeout) 
                -- timeout 为 0 表示立即返回状态而不等待
                -- 返回值: -1 = 正在运行, 0 或正数 = 退出码, -2 = 无效 ID
                local status = vim.fn.jobwait({job_id}, 0)[1]

                if status ~= -1 then
                    -- 进程已退出，强制删除 buffer
                    vim.api.nvim_buf_delete(bufnr, { force = true })
                    closed_count = closed_count + 1
                end
            end
        end
    end

    if closed_count > 0 then
        vim.notify(string.format("清理完毕：已关闭 %d 个已退出的终端", closed_count), vim.log.levels.INFO)
    else
        vim.notify("未发现已退出的终端", vim.log.levels.INFO)
    end
end

-- 2. 注册为用户命令，方便通过 :TermClean 调用
vim.api.nvim_create_user_command('TermClean', cleanup_exited_terminals, {
    desc = '手动清理所有已经退出的终端 Buffer'
})
