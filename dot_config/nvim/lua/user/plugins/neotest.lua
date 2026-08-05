return {
    "nvim-neotest/neotest",
    ft = "rust",
    cmd = "Neotest",
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
