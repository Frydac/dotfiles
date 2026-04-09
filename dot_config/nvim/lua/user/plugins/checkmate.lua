return {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
    opts = {
        -- Avoid fighting Neovim's markdown TS highlighter on startup.
        disable_ts_highlights = true,
        -- files = { "*.md" }, -- any .md file (instead of defaults)
        -- Default keymappings
        keys = {
            ["<BS>tt"] = {
                rhs = "<cmd>Checkmate toggle<CR>",
                desc = "Toggle todo item",
                modes = { "n", "v" },
            },
            ["<BS>tc"] = {
                rhs = "<cmd>Checkmate check<CR>",
                desc = "Set todo item as checked (done)",
                modes = { "n", "v" },
            },
            ["<BS>tu"] = {
                rhs = "<cmd>Checkmate uncheck<CR>",
                desc = "Set todo item as unchecked (not done)",
                modes = { "n", "v" },
            },
            ["<BS>t="] = {
                rhs = "<cmd>Checkmate cycle_next<CR>",
                desc = "Cycle todo item(s) to the next state",
                modes = { "n", "v" },
            },
            ["<BS>t-"] = {
                rhs = "<cmd>Checkmate cycle_previous<CR>",
                desc = "Cycle todo item(s) to the previous state",
                modes = { "n", "v" },
            },
            ["<BS>tn"] = {
                rhs = "<cmd>Checkmate create<CR>",
                desc = "Create todo item",
                modes = { "n", "v" },
            },
            ["<BS>tr"] = {
                rhs = "<cmd>Checkmate remove<CR>",
                desc = "Remove todo marker (convert to text)",
                modes = { "n", "v" },
            },
            ["<BS>tR"] = {
                rhs = "<cmd>Checkmate remove_all_metadata<CR>",
                desc = "Remove all metadata from a todo item",
                modes = { "n", "v" },
            },
            ["<BS>ta"] = {
                rhs = "<cmd>Checkmate archive<CR>",
                desc = "Archive checked/completed todo items (move to bottom section)",
                modes = { "n" },
            },
            ["<BS>tF"] = {
                rhs = "<cmd>Checkmate select_todo<CR>",
                desc = "Open a picker to select a todo from the current buffer",
                modes = { "n" },
            },
            ["<BS>tv"] = {
                rhs = "<cmd>Checkmate metadata select_value<CR>",
                desc = "Update the value of a metadata tag under the cursor",
                modes = { "n" },
            },
            ["<BS>t]"] = {
                rhs = "<cmd>Checkmate metadata jump_next<CR>",
                desc = "Move cursor to next metadata tag",
                modes = { "n" },
            },
            ["<BS>t["] = {
                rhs = "<cmd>Checkmate metadata jump_previous<CR>",
                desc = "Move cursor to previous metadata tag",
                modes = { "n" },
            },
        },
    },
}
