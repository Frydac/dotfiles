return {
    'NeogitOrg/neogit',
    dependencies = 'nvim-lua/plenary.nvim',
    enabled = true,
    cmd = 'Neogit',
    keys = {
        { '<leader>ng', function() require('neogit').open() end, desc = 'Neogit' },
    },
    config = function()
        local neogit = require('neogit')
        neogit.setup {}
    end
}
