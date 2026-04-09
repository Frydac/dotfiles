return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    -- Write a rust AppConfig struct that uses clap to get 0, 1 or more positional arguments for audio files to open, and and optional non-positional argument for start and one for end sample.
    config = function()
        require("codecompanion").setup({
            adapters = {
                http = {
                    openai = function()
                        return require("codecompanion.adapters").extend("openai_responses", {
                            env = {
                                api_key = "",
                            },
                            schema = {
                                model = {
                                    -- Put a model you have access to.
                                    -- See “How to pick a valid model” below.
                                    default = "gpt-5.3-codex",
                                },
                            },
                        })
                    end,
                },
            },
            strategies = {
                chat = { adapter = "openai" },
                inline = { adapter = "openai" },
                cmd = { adapter = "openai" },
            },
        })
        -- require("codecompanion").setup({
        --     adapters = {
        --         openai = function()
        --             return require("codecompanion.adapters").extend("openai_compatible", {
        --                 env = {
        --                     api_key = os.getenv("OPENAI_API_KEY"),
        --                 }
        --             })
        --         end
        --     },
        --     strategies = {
        --         chat = { adapter = "openai" },
        --         inline = { adapter = "openai" },
        --         cmd = { adapter = "openai" },
        --     },

        --     -- strategies = {
        --     --     chat = {
        --     --         adapter = "openai",
        --     --     },
        --     --     inline = {
        --     --         adapter = "openai",
        --     --     },
        --     -- },
        --     -- adapters = {
        --     --     openai = function()
        --     --         return require("codecompanion.adapters").extend("openai", {
        --     --             env = {
        --     --                 api_key =
        --     --                 "",
        --     --             },
        --     --         })
        --     --     end,
        --     -- },
        -- })
    end
}
