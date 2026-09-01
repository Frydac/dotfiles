return {
    'xvzc/chezmoi.nvim',
    enabled = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require("chezmoi").setup {
            -- your configurations
            edit = {
                -- when editing a managed file with chezmoi.nvim, automatically apply changes on save
                watch = true,
            },
        }

        local function chezmoi_path(command, path)
            local result = vim.system({ 'chezmoi', command, path }, { text = true }):wait()
            if result.code ~= 0 then return end
            return vim.trim(result.stdout)
        end

        local function current_paths()
            local path = vim.api.nvim_buf_get_name(0)
            if path == '' then
                vim.notify('Current buffer has no file', vim.log.levels.WARN)
                return
            end

            path = vim.fs.normalize(path)
            local target = chezmoi_path('target-path', path)
            if target then return { source = path, target = target, source_buffer = true } end

            local source = chezmoi_path('source-path', path)
            if source then return { source = source, target = path, source_buffer = false } end

            vim.notify('Current file is not managed by chezmoi', vim.log.levels.WARN)
        end

        local function edit(path)
            vim.cmd.edit(vim.fn.fnameescape(path))
        end

        vim.api.nvim_create_user_command('ChezmoiSource', function()
            local paths = current_paths()
            if paths then edit(paths.source) end
        end, { desc = 'Open chezmoi source for current file' })

        vim.api.nvim_create_user_command('ChezmoiTarget', function()
            local paths = current_paths()
            if paths then edit(paths.target) end
        end, { desc = 'Open chezmoi target for current file' })

        local function apply()
            local paths = current_paths()
            if not paths then return end

            if not paths.source_buffer and vim.bo.modified then
                vim.notify('Target has unsaved changes; use chezmoi re-add instead', vim.log.levels.ERROR)
                return
            end

            if paths.source_buffer and vim.bo.modified then vim.cmd.update() end

            local result = vim.system({ 'chezmoi', 'apply', '--no-tty', paths.target }, { text = true }):wait()
            if result.code ~= 0 then
                local message = vim.trim(result.stderr ~= '' and result.stderr or result.stdout)
                vim.notify(message ~= '' and message or 'chezmoi apply failed', vim.log.levels.ERROR)
                return
            end

            vim.notify('Applied ' .. paths.target)
        end

        vim.api.nvim_create_user_command('ChezmoiApply', apply, { desc = 'Apply current chezmoi file' })
        vim.keymap.set('n', '<leader>za', apply, { desc = 'Apply current chezmoi file' })

        local function diff()
            local paths = current_paths()
            if not paths then return end

            local result = vim.system(
                { 'chezmoi', 'diff', '--no-pager', '--color=false', paths.target },
                { text = true }
            ):wait()
            if result.code ~= 0 then
                local message = vim.trim(result.stderr ~= '' and result.stderr or result.stdout)
                vim.notify(message ~= '' and message or 'chezmoi diff failed', vim.log.levels.ERROR)
                return
            end

            local output = vim.trim(result.stdout)
            if output == '' then
                vim.notify('No chezmoi differences for ' .. paths.target)
                return
            end

            vim.cmd.new()
            local buffer = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_name(buffer, 'chezmoi://diff' .. paths.target)
            vim.bo[buffer].buftype = 'nofile'
            vim.bo[buffer].bufhidden = 'wipe'
            vim.bo[buffer].swapfile = false
            vim.bo[buffer].filetype = 'diff'
            vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(output, '\n', { plain = true }))
            vim.bo[buffer].modifiable = false
        end

        vim.api.nvim_create_user_command('ChezmoiDiff', diff, { desc = 'Diff current chezmoi file' })
        vim.keymap.set('n', '<leader>zd', diff, { desc = 'Diff current chezmoi file' })

        vim.keymap.set('n', '<leader>zt', function()
            local paths = current_paths()
            if paths then edit(paths.source_buffer and paths.target or paths.source) end
        end, { desc = 'Toggle chezmoi source/target' })

        vim.keymap.set('n', '<leader>te',
            function()
                require('telescope').extensions.chezmoi.find_files {
                    file_ignore_patterns = {
                        '/%.config/awesome/lain/',
                    },
                }
            end)
    end
}
