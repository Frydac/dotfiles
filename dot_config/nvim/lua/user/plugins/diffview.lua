return {
    'sindrets/diffview.nvim',
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
