local util = {}

-- insert captured visual selection at requested indentation, and add jump
-- point at the start of the inserted visual block
function util.insert_visual(pos, nr_indent_chars)
    local ls = require("luasnip")
    local sn = ls.snippet_node
    local isn = ls.indent_snippet_node
    local i = ls.insert_node
    local f = ls.function_node

    return sn(pos, {
        i(1),
        isn(2,
            f(function(_, parent)
                local snip = parent.snippet
                return snip.env.SELECT_DEDENT
            end, {})
            , "$PARENT_INDENT" .. string.rep(" ", nr_indent_chars))
    })
end

-- alias for insert_visual
util.iv = util.insert_visual

util.current_buffer_fn = function()
    return vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
end

local RFile = require('related_files.file')

function util.current_buffer_rfile()
    return RFile:new(util.current_buffer_fn())
end

util.namespace = function()
    local fn = util.current_buffer_fn()
    File = require('related_files.file')
    local file = File:new(fn)
    if file.namespace then
        return file.namespace
    else
        return ""
    end
end

function util.find_related_header(rfile)
    rfile = rfile or util.current_buffer_rfile()

end

local M = {}
M.util = util
return M
