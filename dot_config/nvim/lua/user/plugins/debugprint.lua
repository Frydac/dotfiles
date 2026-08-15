-- return {
--     "andrewferrier/debugprint.nvim",
--     config = function()
--         require("debugprint").setup()
--     end,
--     lazy = false,
--     version = "*",
-- }

return {
    "andrewferrier/debugprint.nvim",
    lazy = false,
    version = "*",
    opts = {
        keymaps = {
            normal = {
                plain_below = "<leader>ip",
                plain_above = "<leader>iP",
                variable_below = "<leader>iv",
                variable_above = "<leader>iV",
                variable_below_alwaysprompt = "",
                variable_above_alwaysprompt = "",
                surround_plain = "",
                surround_variable = "",
                surround_variable_alwaysprompt = "",
                textobj_below = "",
                textobj_above = "",
                textobj_surround = "",
                toggle_comment_debug_prints = "",
                delete_debug_prints = "",
            },
            insert = {
                plain = "",
                variable = "",
            },
            visual = {
                variable_below = "<leader>iv",
                variable_above = "<leader>iV",
            },
        },
    },
}


    -- keys = {
    --     {
    --         "<leader>iV",
    --         function()
    --             return require("debugprint").debugprint({ above = true, variable = true })
    --         end,
    --         desc = "[i]nsert [V]ariable debug-print above the current line",
    --         expr = true,
    --         mode = { "n", "v" },
    --     },
    --     {
    --         "<leader>iv",
    --         function()
    --             return require("debugprint").debugprint({ above = false, variable = true })
    --         end,
    --         desc = "[i]nsert [v]ariable debug-print below the current line",
    --         expr = true,
    --         mode = { "n", "v" },
    --     },
    -- },
-- }


-- mapping idea
-- from https://www.reddit.com/r/neovim/comments/1ca3rm8/shoutout_to_andrewferrierdebugprintnvim_add/
-- -- Insert debug print statements easily.
-- {
--     "andrewferrier/debugprint.nvim",
--     config = function()
--         require("debugprint").setup(
--             { create_keymaps = false, create_commands = false }
--         )
--     end,
--     dependencies = { "nvim-treesitter/nvim-treesitter" },
--     keys = {
--         {
--             "<leader>iV",
--             function()
--                 return require("debugprint").debugprint({ above = true, variable = true })
--             end,
--             desc = "[i]nsert [V]ariable debug-print above the current line",
--             expr = true,
--             mode = {"n", "v"},
--         },
--         {
--             "<leader>iv",
--             function()
--                 return require("debugprint").debugprint({ above = false, variable = true })
--             end,
--             desc = "[i]nsert [v]ariable debug-print below the current line",
--             expr = true,
--             mode = {"n", "v"},
--         },
--     },
--     version = "1.*",
-- }
