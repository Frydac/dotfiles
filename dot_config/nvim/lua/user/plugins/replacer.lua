return {
    'gabrielpoca/replacer.nvim',
    config = function ()
        vim.api.nvim_set_keymap('n', '<leader>rep', ':lua require("replacer").run()<cr>', { silent = true })
    end
}
