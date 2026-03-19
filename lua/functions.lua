local function open_remote_ssh_term(opts)
    local projects = {
        {
            local_root  = "/Users/dym/Git/shenchao-MatRIS/MatRIS",
            remote_root = "/home/share/duyiming/MatRIS",
            ssh_host    = "shenchao" 
        },
        {
            local_root  = "/Users/dym/Git/shenchao-MatRIS/MatRIS",
            remote_root = "/home/share/duyiming/MatRIS",
            ssh_host    = "shenchao" 
        },
    }

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

    -- 状态捕获闭包变量
    local cmd_start_time = nil
    local in_tui_mode = false -- 新增：备用屏幕缓冲区状态机标识
    local long_cmd_threshold = 5 -- 长命令判定阈值（秒），可依需修改

    -- 跨平台桌面系统通知实现
    local function trigger_notification(duration)
        local msg = string.format("Remote command finished in %ds", duration)
        local os_name = (vim.uv or vim.loop).os_uname().sysname

        if os_name == "Darwin" then
            -- macOS: 使用 osascript 调用系统级通知和提示音
            local notify_cmd = string.format([[osascript -e 'display notification "%s" with title "Neovim SSH"']], msg)
            os.execute(notify_cmd .. " &")
            os.execute("afplay -v 50 /System/Library/Sounds/Ping.aiff &")
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

    local term_opts = {
        on_stdout = function(_, data, _)
            if not data then return end
            
            -- 将当前数据块拼接，拦截并解析备用屏幕缓冲区切换指令
            local chunk = table.concat(data, "\n")
            
            -- 检测进入备用屏幕缓冲区 (如启动 Vim, htop, less)
            if chunk:find('\27%[%?1049h') or chunk:find('\27%[%?47h') then
                in_tui_mode = true
                cmd_start_time = nil -- 丢弃当前计时，避免累计
            end
            
            -- 检测退出备用屏幕缓冲区 (如退出 Vim)
            if chunk:find('\27%[%?1049l') or chunk:find('\27%[%?47l') then
                in_tui_mode = false
                cmd_start_time = nil -- 重置计时器，防止紧接着出现的 PS1 触发误报
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
            
            -- 验证终端提示符 (支持常规 Bash/Zsh/Fish: 以 $, #, %, 或 > 结尾)
            local is_prompt = clean_line:match("[%#%$%%>]%s*$") ~= nil

            if is_prompt then
                -- 检测到提示符，计算执行时间差
                if cmd_start_time then
                    local duration = os.time() - cmd_start_time
                    if duration >= long_cmd_threshold then
                        trigger_notification(duration)
                    end
                    cmd_start_time = nil
                end
            else
                -- 未检测到提示符，视为有进程执行或键盘输入
                if not cmd_start_time then
                    cmd_start_time = os.time()
                end
            end
        end
    }

    -- 创建窗口并打开终端
    vim.cmd("botright 15new") 
    vim.fn.termopen(ssh_cmd, term_opts)
    
    -- 设置一些终端窗口的常用属性
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    
    -- 4. 如果传了参数，则设置 Buffer 名字
    -- opts.args 是用户输入的字符串
    if opts.args and opts.args ~= "" then
        vim.cmd("file " .. opts.args)
    end
end

-- 注册命令，nargs = '?' 表示参数是可选的 (0个或1个)
vim.api.nvim_create_user_command('RemoteTerm', open_remote_ssh_term, {
    nargs = '?',
    desc = 'Open SSH terminal with optional buffer name'
})
