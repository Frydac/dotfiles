return {
    "gbprod/yanky.nvim",
    keys = {
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Yanky put after" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Yanky put before" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Yanky gput after" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Yanky gput before" },
        { "<c-p>", "<Plug>(YankyCycleForward)", mode = "n", desc = "Yanky cycle forward" },
        { "<M-p>", "<Plug>(YankyCycleBackward)", mode = "n", desc = "Yanky cycle backward" },
    },
    config = function()
        require("yanky").setup({
            ring = {
                history_length = 100,
                storage = "shada",
                sync_with_numbered_registers = true,
                cancel_event = "update",
            },
            picker = {
                select = {
                    action = nil, -- nil to use default put action
                },
                telescope = {
                    mappings = nil, -- nil to use default mappings
                },
            },
            system_clipboard = {
                sync_with_ring = true,
            },
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 150,
            },
            preserve_cursor_position = {
                enabled = true,
            },
        })
    end
}
