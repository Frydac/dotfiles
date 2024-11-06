return {
    "ThePrimeagen/harpoon",
    config = function()
        require("harpoon").setup({
            menu = {
                width = 160
            }
        })
        vim.api.nvim_set_keymap('n', '<BS>a', '<cmd>lua require("harpoon.mark").add_file()<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS><leader>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS>1', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS>2', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS>3', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS>4', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', {})
        vim.api.nvim_set_keymap('n', '<BS>5', '<cmd>lua require("harpoon.ui").nav_file(5)<cr>', {})
    end,
}
