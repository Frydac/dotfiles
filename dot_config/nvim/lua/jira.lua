local util = require('util')
local M = {}

function M.tsv_to_jira_table(add_line_index)
    -- asuming table is lines only
    local start_row, _, end_row, _ = util.visual_selection_range()

    local old_lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
    if (#old_lines == 0) then return end

    local new_lines = {}

    -- header
    local header_line = table.remove(old_lines, 1)
    header_line = "||"..string.gsub(header_line, "\t", "\t||") .."||"
    if add_line_index then header_line = "||\t"..header_line end
    table.insert(new_lines, header_line)

    -- the rest
    for line_ix, old_line in ipairs(old_lines) do
        local new_line = "|"..string.gsub(old_line, "\t", "\t|").."|"
        if add_line_index then new_line = "|"..line_ix.."\t"..new_line end
        table.insert(new_lines, new_line)
    end

    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines)
end


-- debug: reload this file on keymap
-- vim.api.nvim_set_keymap('n', '<leader>asdf', "<cmd>lua Reload('jira')<cr>", {})

vim.cmd [[command! -range TsvToJiraTable :<line1>,<line2>lua require('jira').tsv_to_jira_table(false)<cr>]]
vim.cmd [[command! -range TsvToJiraTableAddIndex :<line1>,<line2>lua require('jira').tsv_to_jira_table(true)<cr>]]

return M
