return {
    "supermaven-inc/supermaven-nvim",
    config = function()
        require("supermaven-nvim").setup({
            keymaps = {
                accept_suggestion = "<M-f>",
                clear_suggestion = "<M-e>",
                accept_word = "<M-w>",
            },
        })
    end,
}
