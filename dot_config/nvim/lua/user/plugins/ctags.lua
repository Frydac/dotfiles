return {
    {
        "ludovicchabant/vim-gutentags",
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
        config = function()
            vim.g.tagbar_position = "botleft vertical"
            -- vim.api.nvim_set_keymap("n", "<leader>tb", "<cmd>TagbarToggle<cr>", {})
            vim.api.nvim_set_keymap("n", "<leader>tb", "<cmd>TagbarOpenAutoClose<cr>", {})
        end,
    },
}
