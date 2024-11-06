return {
    'phaazon/hop.nvim',
    config = function()
        if not pcall(require, 'hop') then return end

        local hop = require('hop')
        hop.setup()

        -- vim.keymap.set('n', 'f',
        --     function()
        --         hop.hint_char1({
        --             direction = require('hop.hint').HintDirection.AFTER_CURSOR,
        --             current_line_only = true
        --         })
        --     end)
        -- vim.keymap.set('n', 'F',
        --     function()
        --         hop.hint_char1({
        --             direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
        --             current_line_only = true
        --         })
        --     end)
        --
        -- vim.keymap.set('n', 't',
        --     function()
        --         hop.hint_char1({
        --             direction = require('hop.hint').HintDirection.AFTER_CURSOR,
        --             current_line_only = true,
        --             hint_offset = -1
        --         })
        --     end)
        -- vim.keymap.set('n', 'T',
        --     function()
        --         hop.hint_char1({
        --             direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
        --             current_line_only = true,
        --             hint_offset = -1
        --         })
        --     end)
        vim.keymap.set('n', 's', function() hop.hint_char1({}) end)
        vim.keymap.set('n', 'S', function() hop.hint_char2({}) end)
    end
}
