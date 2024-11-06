return {
    {
        "AndrewRadev/sideways.vim",

        config = function()
            vim.cmd([[
            nnoremap <C-Left> :SidewaysLeft<cr>
            nnoremap <C-Right> :SidewaysRight<cr>
            ]])
        end,
    },
    {
        'Wansmer/sibling-swap.nvim',
        requires = { 'nvim-treesitter' },
        config = function()
            require('sibling-swap').setup({
                -- use_default_keymaps = false,
                -- keymaps = {
                --     ['<C-Right>'] = 'swap_with_right',
                --     ['<C-Left>'] = 'swap_with_left',
                --     ['<space>Right'] = 'swap_with_right_with_opp',
                --     ['<space>Left'] = 'swap_with_left_with_opp',
                -- },
            })
        end,
    }
}
