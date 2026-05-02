return {
    "kevinhwang91/nvim-hlslens",
    disable = false,
    keys = {
        { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], desc = 'Next search result' },
        { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], desc = 'Previous search result' },
        { '*', [[*<Cmd>lua require('hlslens').start()<CR>]], desc = 'Search word forward' },
        { '#', [[#<Cmd>lua require('hlslens').start()<CR>]], desc = 'Search word backward' },
        { 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], desc = 'Search word forward partial' },
        { 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], desc = 'Search word backward partial' },
    },
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

        -- vim.api.nvim_set_keymap('n', '<Leader>l', ':noh<CR>', kopts)
    end,
}
