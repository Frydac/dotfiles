return {
    'madskjeldgaard/cppman.nvim',
    dependencies = {
        { 'MunifTanjim/nui.nvim' }
    },
    keys = {
        { "<leader>cpm", function() require("cppman").open_cppman_for(vim.fn.expand("<cword>")) end, desc = "CPPman word" },
        { "<leader>cps", function() require("cppman").input() end, desc = "CPPman search" },
    },
    config = function()
        require("cppman").setup()
    end
}
