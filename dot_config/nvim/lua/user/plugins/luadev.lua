return {
    {
        "bfredl/nvim-luadev",
        config = function()
            vim.api.nvim_set_keymap("v", "<leader>x", "<Plug>(Luadev-Run)", {})
            vim.api.nvim_set_keymap("n", "<leader>x", "<Plug>(Luadev-RunLine)", {})
        end,

    },
}

