-- Constructs ripgrep query to find any file that includes the current buffer.
-- depends on filtype, not everyting supported of course

local M = {}

local remove_extension = function (filename)
    if filename then
        return vim.fn.fnamemodify(filename, ':r')
    end
end
local basename = function (filename)
    if filename then
        return vim.fn.fnamemodify(filename, ':p:t')
    end
end

-- NOTE:
-- lua string theory:
-- [====[ raw string literal that can contain ]] or end with ]]====]

local function create_ripgrep_query_cpp(include_path, full_include_path_known)
    local query = [[include\s*]]
    if full_include_path_known then
        -- `<` or `"`
        query = query .. [=[[<\"]]=]
    else
        query = query .. ".*"
    end

    query = query .. include_path

    if full_include_path_known then
        query = query .. [=[[>\"]]=]
    end

    query = [[-tcpp -tc "]]..query..[["]]

    return query
end

local function create_ripgrep_query_ruby(include_path, full_include_path_known)
    local query = [[require\s*\(?]]

    if full_include_path_known then
        query = query .. [=[[\"']]=]
    end

    include_path = remove_extension(include_path)

    query = query .. include_path

    if full_include_path_known then
        query = query .. [=[[\"']]=]
    end

    query = [[-truby "]]..query..[["]]

    return query
end

local function create_ripgrep_query_lua(include_path, full_include_path_known)
    -- TODO: pcall (require, 'path.to.file')
    local query = [[require]]

    if full_include_path_known then
        query = query .. [=[\s*\(?\s*[\"']]=]
    else
        query = query .. [=[.*[\.\"']]=]
    end

    local include_path_pts = remove_extension(include_path):gsub([[/]], [[.]])
    query = query .. include_path_pts

    if full_include_path_known then
        query = query .. [=[[\"']]=]
    end

    query = [[-tlua "]]..query..[["]]

    return query
end

-- table of functions with as key the vim.filetype
local create_ripgrep_query = {
    cpp = create_ripgrep_query_cpp,
    c = create_ripgrep_query_cpp,
    ruby = create_ripgrep_query_ruby,
    lua =create_ripgrep_query_lua
}

function M.find_where_included(filename)

    -- create include path based on related files, or just use the basename
    local include_path = ""
    local full_include_path_known = false

    local rfile_ok, RFile = pcall(require, "related_files.file")
    if (rfile_ok) then
        local rfile = RFile:new(filename)

        if rfile.namespace then
            include_path = rfile.namespace
            full_include_path_known = true
        end
        include_path = include_path .. rfile.basename
    end

    if include_path == "" then
        include_path = basename(filename)
    end

    -- TODO: this doesn't work for "<path>.h" files..??
    -- local vim_filetype = vim.filetype.match({ filename = filename })
    local vim_filetype = vim.filetype.match({ buf = vim.api.nvim_get_current_buf() })
    local create_query_func = create_ripgrep_query[vim_filetype]
    if (create_query_func) then
        local rg_query = create_query_func(include_path, full_include_path_known)
        local cmd = string.format("Rg -u %s", rg_query)
        print("Search command: "..cmd)
        vim.cmd(cmd)
    end
end

function M.find_where_included_current_buf()
    local current_buf_fn = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    return M.find_where_included(current_buf_fn)
end

vim.keymap.set('n', 'ydf', function() M.find_where_included_current_buf() end)

return M


-- TODO: 
-- doesn't work as expected for file: comp/apm/test/protected/auro/apm/v1/construct/Bed.hpp
