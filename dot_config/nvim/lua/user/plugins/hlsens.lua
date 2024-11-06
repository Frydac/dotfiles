return {
    "kevinhwang91/nvim-hlslens",
    disable = false,
    config = function()
        -- vim.cmd([[
        --     noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>
        --     noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>
        --     noremap * *<Cmd>lua require('hlslens').start()<CR>
        --     noremap # #<Cmd>lua require('hlslens').start()<CR>
        --     noremap g* g*<Cmd>lua require('hlslens').start()<CR>
        --     noremap g# g#<Cmd>lua require('hlslens').start()<CR>
        -- ]])
        -- lua
        require("hlslens").setup({
            -- calm_down = true,
            nearest_only = true,
            -- nearest_float_when = 'always'
        })

        local kopts = { noremap = true, silent = true }

        vim.api.nvim_set_keymap('n', 'n',
            [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
            kopts)
        vim.api.nvim_set_keymap('n', 'N',
            [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
            kopts)
        vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
        vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
        vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
        vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

        -- vim.api.nvim_set_keymap('n', '<Leader>l', ':noh<CR>', kopts)
    end,
}
