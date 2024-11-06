return { "t9md/vim-quickhl",
    config = function()
        vim.keymap.set({ 'n', 'x' }, '<leader>m', '<Plug>(quickhl-manual-this)')
        vim.keymap.set({ 'n', 'x' }, '<leader><leader>m', '<Plug>(quickhl-manual-reset)')
    end
}
