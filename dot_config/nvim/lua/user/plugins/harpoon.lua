return {
    "ThePrimeagen/harpoon",
    keys = {
        { '<BS>a', function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
        { '<BS><leader>', function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
        { '<BS>1', function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
        { '<BS>2', function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
        { '<BS>3', function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
        { '<BS>4', function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
        { '<BS>5', function() require("harpoon.ui").nav_file(5) end, desc = "Harpoon file 5" },
    },
    config = function()
        require("harpoon").setup({
            menu = {
                width = 160
            }
        })
    end,
}
