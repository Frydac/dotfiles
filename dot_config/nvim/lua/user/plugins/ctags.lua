return {
    {
        "ludovicchabant/vim-gutentags",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.g.gutentags_ctags_exclude = { ".ccls*", "*.git", "*.svg", "*.hg", "*.json", "*/.ccls-*" }
            vim.g.gutentags_exclude_filetypes = {
                "gitcommit",
                "gitconfig",
                "gitrebase",
                "gitsendemail",
                "git",
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
