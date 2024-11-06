return {
    -- get link to online repository, usage: `<leader>gy` on a selection
    'ruifm/gitlinker.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function() require("gitlinker").setup() end
}
