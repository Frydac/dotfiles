local function find_first_ancestor_with_git(path)
    local first_ancestor = vim.fs.dirname(vim.fs.find(".git", { path = path, upward = true })[1])
    if not first_ancestor then
        print("No ancestor found with '.git'")
    end
    return first_ancestor
end

local function find_last_ancestor_with_git(path)
    -- NOTE: we assume no more than 5 git repositories in the ancestors (limit defaults to 1)
    local ancestors = vim.fs.find(".git", { path = path, upward = true, limit = 5 })
    local last_ancestor = ancestors and vim.fs.dirname(ancestors[#ancestors]) or nil
    if not last_ancestor then
        print("No ancestor found with '.git'")
    end
    return last_ancestor
end

local function cd_to(dir)
    if dir and dir ~= vim.fn.getcwd() then
        vim.api.nvim_set_current_dir(dir)
        print('Changed cwd to: "' .. dir .. '"')
    else
        print("Didn't change cwd. cwd: \"" .. vim.fn.getcwd() .. '"')
    end
end

vim.keymap.set("n", "<leader>cm",
    function()
        cd_to(find_first_ancestor_with_git(vim.api.nvim_buf_get_name(0)))
    end,
    { desc = "Change Module: change cwd to the git module (repository) containing current buffer" }
)

vim.keymap.set("n", "<leader>cs",
    function()
        cd_to(find_last_ancestor_with_git(vim.api.nvim_buf_get_name(0)))
    end,
    { desc = "Change Super-module: change cwd to the git super-module containing current buffer" }
)

vim.keymap.set("n", "<leader>cd", function()
    cd_to(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
end,
    { desc = "Change Dirname: cwd to the directory containing current buffer" }
)
