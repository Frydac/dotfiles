return {
    {
        "junegunn/vim-easy-align",
        config = function()
            vim.cmd([[
            " Start interactive EasyAlign in visual mode (e.g. vipga)
            xmap ga <Plug>(EasyAlign)
            " Start interactive EasyAlign for a motion/text object (e.g. gaip)
            " TODO: find other mapping, ga is used to print character under cursor"
            " nmap ga <Plug>(EasyAlign)
            ]])
        end,
    }, {
        "godlygeek/tabular",
        config = function()
            vim.cmd([[
            nnoremap <leader>ab :Tabularize /
            vnoremap <leader>ab :Tabularize /
            ]])
        end,
    }
}
