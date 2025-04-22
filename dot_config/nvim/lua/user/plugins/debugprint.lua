return {
    "andrewferrier/debugprint.nvim",
    config = function()
        require("debugprint").setup()
    end,
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
}


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
