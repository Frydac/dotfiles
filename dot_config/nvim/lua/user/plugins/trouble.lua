return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        position = "left", -- instead of bottom
    },
    keys = {
        {
            "<leader>do",
            function()
                require("trouble").open({ mode = "diagnostics" })
            end,
            desc = "Open diagnostics (Trouble)",
        },
        {
            "<leader>dn",
            function()
                require("trouble").next({ mode = "diagnostics", jump = true })
            end,
            desc = "Next diagnostic (Trouble)",
        },
        {
            "<leader>dp",
            function()
                require("trouble").prev({ mode = "diagnostics", jump = true })
            end,
            desc = "Previous diagnostic (Trouble)",
        },
    },
}
