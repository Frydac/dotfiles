return {
    {
        "jackMort/ChatGPT.nvim",
        config = function()
            -- vim.env.OPENAI_API_KEY = "nope"
            vim.env.OPENAI_API_KEY = "nope"
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
    -- {
    --     'aduros/ai.vim',
    --     config = function()
    --         vim.g.ai_no_mappings = true
    --     end
    -- }
}
