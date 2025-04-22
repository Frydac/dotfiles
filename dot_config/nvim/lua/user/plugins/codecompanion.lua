return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    -- Write a rust AppConfig struct that uses clap to get 0, 1 or more positional arguments for audio files to open, and and optional non-positional argument for start and one for end sample.
    config = function()
        require("codecompanion").setup({
            strategies = {
                chat = {
                    adapter = "openai",
                },
                inline = {
                    adapter = "openai",
                },
            },
            adapters = {
                openai = function()
                    return require("codecompanion.adapters").extend("openai", {
                        env = {
                        },
                    })
                end,
            },
        })
    end
}
