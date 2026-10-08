local function git_submodules(recursive)
    local root_result = vim.system({ "git", "rev-parse", "--show-toplevel" }, {
        cwd = vim.fn.getcwd(),
        text = true,
    }):wait()
    if root_result.code ~= 0 then
        vim.notify("Current directory is not in a Git repository", vim.log.levels.WARN)
        return
    end
    local root = vim.trim(root_result.stdout)
    local command = { "git", "submodule", "foreach", "--quiet" }
    if recursive then
        table.insert(command, "--recursive")
    end
    table.insert(command, [[printf '%s\n' "$displaypath"]])

    vim.system(command, { cwd = root, text = true }, function(result)
        vim.schedule(function()
            if result.code ~= 0 then
                vim.notify(vim.trim(result.stderr), vim.log.levels.ERROR)
                return
            end
            local paths = vim.split(result.stdout, "\n", { trimempty = true })
            if #paths == 0 then
                vim.notify("No checked-out submodules found", vim.log.levels.INFO)
                return
            end

            local function selected_path(selected)
                return selected[1] and (root .. "/" .. selected[1])
            end

            require("fzf-lua").fzf_exec(paths, {
                cwd = root,
                prompt = recursive and "Submodules (recursive)> " or "Submodules> ",
                preview = "git --no-optional-locks -C {} status --short --branch",
                fzf_opts = {
                    ["--no-multi"] = true,
                    ["--header"] = "Enter: Fugitive status | Ctrl-D: cd | Ctrl-F: files",
                },
                actions = {
                    ["default"] = function(selected)
                        local path = selected_path(selected)
                        if not path then
                            return
                        end
                        require("lazy").load({ plugins = { "vim-fugitive" } })
                        -- Use Fugitive's command dispatcher with an explicit repository:
                        -- :Git rejects -C, and changing cwd alone can use the current buffer's repo.
                        local git_dir = vim.fn.FugitiveExtractGitDir(path .. "/.git")
                        local status_command = vim.fn["fugitive#Command"](0, -1, 0, 0, "vertical", "", git_dir)
                        vim.cmd(status_command)
                    end,
                    ["ctrl-d"] = function(selected)
                        local path = selected_path(selected)
                        if path then
                            vim.cmd.cd(vim.fn.fnameescape(path))
                        end
                    end,
                    ["ctrl-f"] = function(selected)
                        local path = selected_path(selected)
                        if path then
                            require("fzf-lua").files({ cwd = path })
                        end
                    end,
                },
            })
        end)
    end)
end

return {
    "ibhagwan/fzf-lua",
    cmd = { "FzfLua", "GitSubmodules" },
    keys = {
        {
            "<leader>gS",
            function()
                git_submodules(true)
            end,
            desc = "Git submodules",
        },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        vim.api.nvim_create_user_command("GitSubmodules", function(opts)
            git_submodules(not opts.bang)
        end, { bang = true, desc = "Pick Git submodules (!: direct only)" })
        require("fzf-lua").setup({
            winopts = {
                width = 0.9,
                height = 0.9,
                preview = {
                    horizontal = "right:40%",
                },
            },
            fzf_opts = {
                -- prompt on bottom
                ["--layout"] = "default",
            },
            oldfiles = {
                include_current_session = true,
            },
        })
    end,
}
