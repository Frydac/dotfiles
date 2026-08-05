return {
    {
        "ludovicchabant/vim-gutentags",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.g.gutentags_ctags_exclude = {
                ".ccls*",
                "*.git",
                "*.svg",
                "*.hg",
                "*.json",
                "*/.ccls-*",
                -- Wine/Proton prefixes contain a `z: -> /` drive symlink that
                -- crawls the whole filesystem in an infinite loop. ctags does
                -- NOT read ~/.ignore, so it must be excluded here explicitly.
                "z:",
                "dosdevices",
                "compatdata",
                "steamapps",
                ".steam",
                "Steam",
                ".wine",
                ".local/share/lutris",
                ".local/share/bottles",
            }
            -- Belt-and-suspenders: never follow symlinks, so no symlink loop
            -- (Steam z:->/ or otherwise) can ever make ctags crawl the FS.
            vim.g.gutentags_ctags_extra_args = { "--links=no" }
            -- Never treat $HOME as a project root. Without this, editing a file
            -- under ~ with no closer project marker (e.g. ~/notes/*.md) makes
            -- gutentags scan the entire home dir.
            vim.g.gutentags_exclude_project_root = { "/usr/local", vim.env.HOME }
            vim.g.gutentags_exclude_filetypes = {
                "gitcommit",
                "gitconfig",
                "gitrebase",
                "gitsendemail",
                "git",
                "markdown",
            }
            -- vim.g.gutentags_trace = 1
            -- vim.g.gutentags_cache_dir = '~/tmp/'
        end,
    },
    {
        "preservim/tagbar",
        cmd = { "TagbarToggle", "TagbarOpenAutoClose", "TagbarOpen" },
        keys = {
            { "<leader>tb", "<cmd>TagbarOpenAutoClose<cr>", desc = "Tagbar" },
        },
        config = function()
            vim.g.tagbar_position = "botleft vertical"
        end,
    },
}
