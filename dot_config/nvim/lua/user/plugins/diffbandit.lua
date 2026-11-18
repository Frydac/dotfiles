return {
    "CoreyKaylor/diffbandit.nvim",
    config = function()
        require("diffbandit").setup()
        vim.keymap.set('n', '<leader>ggd', function ()
            require('diffbandit').commit_panel()
        end)

    end,
    -- keys = {
    -- }
}
