return {
    'shortcuts/no-neck-pain.nvim',
    config = function()
        -- only take a way left side
        require("no-neck-pain").setup({
            buffers = {
                right = {
                    enabled = false,
                },
            },
        })

        vim.keymap.set("n", "<leader>nn", "<cmd>NoNeckPain<cr>")
    end
}
