return {
    -- A code outline window for skimming and quick navigation
    -- works better with ruby than outline
    "stevearc/aerial.nvim",
    config = function()
        require("aerial").setup({
            layout = {
                min_width = 40
            },
            default_direction = "prefer_left",
        })
        -- Example mapping to toggle outline
        vim.keymap.set("n", "<leader>aa", "<cmd>AerialToggle<CR>",
            { desc = "Toggle Aerial" })
    end,
}
