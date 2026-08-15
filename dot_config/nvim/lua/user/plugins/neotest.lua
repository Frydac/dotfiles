return {
    "nvim-neotest/neotest",
        event = "VeryLazy",
        ft = "rust",
        cmd = {
            "Neotest",
            "Neotest summary",
            "Neotest output",
            "Neotest output-panel",
            "Neotest run",
            "Neotest stop",
            "Neotest jump",
        },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            require('neotest').setup {
                output_panel = {
                    enabled = true,
                    open = "leftabove vsplit",
                },
                adapters = {
                    require('rustaceanvim.neotest')
                },
            }
    end
}
