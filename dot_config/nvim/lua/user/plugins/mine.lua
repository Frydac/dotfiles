return {
    "Frydac/vim-auro", -- not needed anymore, use <leader>ydf iso af
    "Frydac/vim-tree",
    {
        -- "git@github.com:Frydac/related_files.nvim",
        "Frydac/related_files.nvim",
        config = function()
            require("related_files").setup()
            vim.cmd([[
                nmap <leader>! <c-w>v<leader>1
                nmap <leader>@ <c-w>v<leader>2
                " TODO: already taken by Marks -> need to replace that
                " nmap <leader># <c-w>v<leader>3
                nmap <leader>$ <c-w>v<leader>4
            ]])
        end,
    },
    {
        url = "https://codeberg.org/emi/util.nvim.git",
    }
}
