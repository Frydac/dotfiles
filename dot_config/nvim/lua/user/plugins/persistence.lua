return {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    keys = { "<leader>ss", "<leader>sl", "<leader>sd" }, -- we also want to be able to just load the session before opening a file
    config = function()
        require("persistence").setup({
            -- defaults to config dir, but I don't want it in my config git repo
            dir = vim.fn.expand(vim.fn.stdpath("data") .. "/sessions/")
        })

        -- restore the session for the current directory
        vim.keymap.set("n", "<leader>ss", function() require("persistence").load() end, {})

        -- restore the last session
        vim.keymap.set("n", "<leader>sl", function() require("persistence").load({ last = true }) end, {})

        -- stop Persistence => session won't be saved on exit
        vim.keymap.set("n", "<leader>sd", function() require("persistence").stop() end, {})
    end,
}
