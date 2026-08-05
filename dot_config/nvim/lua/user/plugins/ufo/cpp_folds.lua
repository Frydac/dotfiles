local M = {}

local function strip_cpp_noise(line, in_block_comment)
    local out = {}
    local i = 1

    while i <= #line do
        if in_block_comment then
            local finish = line:find('*/', i, true)
            if not finish then
                return '', true
            end
            in_block_comment = false
            i = finish + 2
        else
            local two = line:sub(i, i + 1)
            local char = line:sub(i, i)

            if two == '//' then
                break
            elseif two == '/*' then
                in_block_comment = true
                i = i + 2
            elseif char == '"' or char == "'" then
                local quote = char
                i = i + 1
                while i <= #line do
                    local current = line:sub(i, i)
                    if current == '\\' then
                        i = i + 2
                    elseif current == quote then
                        i = i + 1
                        break
                    else
                        i = i + 1
                    end
                end
            else
                table.insert(out, char)
                i = i + 1
            end
        end
    end

    return table.concat(out), in_block_comment
end

local function get_test_case_folds(bufnr)
    local ranges = {}
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local lnum = 1

    while lnum <= line_count do
        local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ''

        if line:match('^%s*TEST_CASE[%w_]*%s*%(') then
            local body_start
            local body_end
            local depth = 0
            local in_block_comment = false

            for scan_lnum = lnum, line_count do
                local scan_line = vim.api.nvim_buf_get_lines(bufnr, scan_lnum - 1, scan_lnum, false)[1] or ''
                local code
                code, in_block_comment = strip_cpp_noise(scan_line, in_block_comment)

                for char in code:gmatch('.') do
                    if char == '{' then
                        body_start = body_start or scan_lnum
                        depth = depth + 1
                    elseif char == '}' and body_start then
                        depth = depth - 1
                        if depth == 0 then
                            body_end = scan_lnum
                            break
                        end
                    end
                end

                if body_end then
                    break
                end
            end

            if body_start and body_end and body_end > lnum then
                table.insert(ranges, {
                    startLine = lnum - 1,
                    endLine = body_end - 1,
                })
                lnum = body_end
            end
        end

        lnum = lnum + 1
    end

    return ranges
end

local function get_default_folds(bufnr)
    local ok, ranges = pcall(require('ufo').getFolds, bufnr, 'treesitter')
    if not ok or type(ranges) ~= 'table' then
        ok, ranges = pcall(require('ufo').getFolds, bufnr, 'indent')
    end

    return ok and type(ranges) == 'table' and ranges or {}
end

local function get_if_else_body_folds(bufnr, language)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
    if not ok or not parser then
        return {}
    end

    local query_ok, query = pcall(vim.treesitter.query.parse, language, [[
        (if_statement
          consequence: (compound_statement) @if_body)

        (else_clause
          (compound_statement) @else_body)
    ]])
    if not query_ok then
        return {}
    end

    local tree = parser:parse()[1]
    if not tree then
        return {}
    end

    local ranges = {}
    for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
        local parent = node:parent()
        if parent then
            local start_row = node:range()
            local parent_start_row = parent:range()

            if start_row > parent_start_row then
                local _, _, end_row = node:range()
                if end_row > start_row then
                    table.insert(ranges, {
                        startLine = start_row,
                        endLine = end_row,
                    })
                end
            end
        end
    end

    return ranges
end

local function get_language(bufnr)
    local filetype = vim.bo[bufnr].filetype
    if filetype == 'c' or filetype == 'cpp' then
        return filetype
    end
    return 'cpp'
end

-- Treesitter folds C++ blocks inside doctest tests, but TEST_CASE_* itself is a macro, so it
-- is not exposed as a nice top-level fold. Keep ufo's normal folds, then add one extra range
-- per doctest test by scanning from TEST_CASE_* to the matching closing brace.
--
-- Also add C/C++ folds for separate-line if/else bodies. The normal if_statement fold is kept, so
-- `zc` on the `if (...)` line still closes the whole if/else chain; `zc` on the standalone `{` line
-- or inside that body can close only that branch.
function M.get_c_cpp_folds(bufnr)
    local ranges = get_default_folds(bufnr)
    local language = get_language(bufnr)

    for _, range in ipairs(get_test_case_folds(bufnr)) do
        table.insert(ranges, range)
    end

    for _, range in ipairs(get_if_else_body_folds(bufnr, language)) do
        table.insert(ranges, range)
    end

    return ranges
end

M.get_cpp_folds = M.get_c_cpp_folds

return M
