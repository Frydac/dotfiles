return {
    'MagicDuck/grug-far.nvim',
    keys = {
        { "<leader>sr", function() require('grug-far').open() end, desc = "Search/replace" },
    },
    config = function()
        require('grug-far').setup({});
    end
}
