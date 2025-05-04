return {
    {
        "jackMort/ChatGPT.nvim",
        config = function()
            vim.env.OPENAI_API_KEY = ""
            require("chatgpt").setup({
                -- optional configuration
            })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        },
    },
}
