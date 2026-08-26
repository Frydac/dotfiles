return {
    -- A code outline window for skimming and quick navigation
    -- works better with ruby than outline
    "stevearc/aerial.nvim",
    config = function()
        require("aerial").setup()
        -- Example mapping to toggle outline
        vim.keymap.set("n", "<leader>aa", "<cmd>AerialToggle<CR>",
            { desc = "Toggle Aerial" })
    end,
}
