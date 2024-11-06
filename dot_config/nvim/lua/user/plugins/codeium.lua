return {
    -- The one with cmp integration
    -- {
    --     "jcdickinson/codeium.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "hrsh7th/nvim-cmp",
    --     },
    --     config = function()
    --         require("codeium").setup({
    --         })
    --     end
    -- },

    -- -- The default one
    -- {
    --     "Exafunction/codeium.vim",
    --     config = function()
    --         vim.g.codeium_disable_bindings = 1
    --         vim.keymap.set('i', '<C-o>', function() return vim.fn['codeium#Accept']() end, { expr = true })
    --         vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
    --         vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
    --         vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
    --     end
    -- },

    -- add this to the file where you setup your other plugins:
    {
        "monkoose/neocodeium",
        event = "VeryLazy",
        config = function()
            local neocodeium = require("neocodeium")
            neocodeium.setup()
            vim.keymap.set("i", "<M-f>", function() require("neocodeium").accept() end)
            vim.keymap.set("i", "<M-w>", function() require("neocodeium").accept_word() end)
            vim.keymap.set("i", "<M-a>", function() require("neocodeium").accept_line() end)
            vim.keymap.set("i", "<M-e>", function() require("neocodeium").cycle_or_complete() end)
            vim.keymap.set("i", "<M-r>", function() require("neocodeium").cycle_or_complete(-1) end)
            vim.keymap.set("i", "<M-c>", function() require("neocodeium").clear() end)
        end,

    }
}
