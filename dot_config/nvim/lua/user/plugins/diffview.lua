return {
    'dlyongemallo/diffview-plus.nvim',
    version = '*',
    cmd = {
        'DiffviewOpen',
        'DiffviewClose',
        'DiffviewToggleFiles',
        'DiffviewFocusFiles',
        'DiffviewFileHistory',
        'DiffviewRefresh',
        'DiffviewLog',
    },
    config = function()
        require('diffview').setup {}
    end
}
