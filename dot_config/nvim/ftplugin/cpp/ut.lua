local Stack = require("user.stack")

local function find_last_ancestor_with_git(path)
    -- NOTE: we assume no more than 5 git repositories in the ancestors (limit defaults to 1)
    local ancestors = vim.fs.find(".git", { path = path, upward = true, limit = 5 })
    local last_ancestor = ancestors and vim.fs.dirname(ancestors[#ancestors]) or nil
    if not last_ancestor then
        print("No ancestor found with '.git'")
    end
    return last_ancestor
end

local function get_submodule(rfile)
    local ancestor = find_last_ancestor_with_git(rfile.parent)

    -- subtrack ancestor from rfile.parent
    local submodule_dir = rfile.parent:sub(#ancestor + 2, -1)
    L("submodule_dir: ", submodule_dir)
    return submodule_dir
end

local function get_version(rfile)
    -- find substring "/v<nr>/" and remove the first slash
    print("rfile.namespace: " .. rfile.namespace)
    if rfile.namespace then
        local m = rfile.namespace:match([[/v%d+/]])
        if m then
            return m:sub(2, -1)
        end
    end
    return ""
end

local function get_access(rfile)
    -- if the table in rfile.pargen_type contains public, protected or private, return the value
    if rfile.pargen_type.public then
        return "public"
    elseif rfile.pargen_type.protected then
        return "protected"
    elseif rfile.pargen_type.private then
        return "private"
    else
        error("not supported")
    end
end

local function get_module_uri(rfile)
    local subm_dir = get_submodule(rfile)
    local version = get_version(rfile)
    local access = get_access(rfile)
    local uri = subm_dir .. version .. access
    return uri
end

local function find_test_case_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line_nr = cursor[1] -- 1 based

    for line_nr = cursor_line_nr - 1, 0, -1 do
        local line = vim.api.nvim_buf_get_lines(0, line_nr, line_nr + 1, false)[1] -- 0 based, open end
        if line:find("TEST_CASE") then
            return line, line_nr
        end
    end

    print("No TEST_CASE found above current cursor position")
end

local function find_test_cast_tags_in_line(line)
    local tags = {}
    for tag in line:gmatch("%[([^%]]+)%]") do
        table.insert(tags, tag)
    end
    return tags
end

-- find all tags in string line '"description", "[tag1][tag2]"'
local function find_test_case_tags()
    local line, line_nr = find_test_case_line()
    local tags = find_test_cast_tags_in_line(line)
    if #tags == 0 then
        print("No tags found in line: ", line)
        return nil
    end
    return tags, line_nr
end

-- returns nil if no brackets
-- returns positive number for nr of excess open brackets
-- returns negative number for nr of excess close brackets
-- returns zero when brackets are balanced
local function get_brackets_count(line)
    local nr_open_brackets = 0
    for _ in line:gmatch("{") do
        nr_open_brackets = nr_open_brackets + 1
    end
    local nr_close_brackets = 0
    for _ in line:gmatch("}") do
        nr_close_brackets = nr_close_brackets + 1
    end

    if (nr_close_brackets == 0 and nr_open_brackets == 0) then
        return nil
    end

    return nr_open_brackets - nr_close_brackets
end

local function adjust_bracket_count_current_section(sections, line)
    if sections:empty() then
        -- no current section, brackets can be ignored
        return
    end

    local line_bracket_count = get_brackets_count(line)
    if line_bracket_count == nil then
        -- no brackets -> nothing change for the current section
        return
    end

    local current_section = sections:top()
    if current_section.bracket_count == nil then
        -- it could be we haven't yet encountered any brackets, we have now, so set to a number we can operate on
        current_section.bracket_count = 0
    end
    current_section.bracket_count = current_section.bracket_count + line_bracket_count
    if current_section.bracket_count == 0 then
        -- we had at least one open bracket and counted back to a matching closed bracket = section closed
        sections:pop()
    end

end

local function find_sections_around_cursor(test_case_line_nr)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line_nr = cursor[1] -- 1 based
    local sections = Stack:new()

    -- get all the lines from test_case_line_nr to current cursor line
    local lines = vim.api.nvim_buf_get_lines(0, test_case_line_nr, cursor_line_nr, false) -- 0 based, open end

    for line_nr, line in ipairs(lines) do
        -- last line = cursor line -> cut off line at cursor
        if line_nr == #lines then line = line:sub(1, cursor[2]) end

        local section_name = line:match([[SECTION%("([^"]+)"%)]])
        if section_name then
            local plain_not_pattern = true
            local section_name_pos = line:find(section_name, 1, plain_not_pattern)
            if not section_name_pos then
                error("Could not find section name '" .. section_name .. "' in line: " .. line)
            end
            local section_name_end_pos = section_name_pos + #section_name

            -- special case where the cursor line is on the line with the section
            if line_nr == #lines then
                if cursor[2] < section_name_pos then
                    -- if cursor is before the section, we asume you still want this section anyway
                    sections:push({ section = section_name, bracket_count = nil })
                    goto after_for
                end
            end

            -- count brackets before matched section and adjuste stack/previous section accordingly
            local line_before_section = line:sub(1, section_name_pos - 1)
            adjust_bracket_count_current_section(sections, line_before_section)
            -- add found section to stack
            sections:push({ section = section_name, bracket_count = nil })

            -- count brackets after matched section and adjust matched section accordingly
            local line_after_section = line:sub(section_name_end_pos)
            adjust_bracket_count_current_section(sections, line_after_section)

        else
            adjust_bracket_count_current_section(sections, line)
        end
    end

    ::after_for::
    local sections_list = {}
    for _, section in ipairs(sections._stack) do
        table.insert(sections_list, section.section)
    end

    if #sections_list == 0 then
        return nil
    end
    return sections_list
end

vim.keymap.set('n', '<leader>aut', function()
    local RFile = require('related_files.file')
    local rfile = RFile:new()
    local uri = get_module_uri(rfile)
    local ut = "rake ut[" .. uri

    local tags = find_test_case_tags()
    if tags then
        ut = ut .. "," .. table.concat(tags, ":")
    end

    ut = ut .. "]"

    print("ut: " .. ut)

    -- set default register to ut string, in line mode
    vim.fn.setreg('"', ut, "l")
    vim.fn.setreg('+', ut)

end, {
    desc = "Create unit test command for the unit test TEST_CASE for the cursor position/line"
})

vim.keymap.set('n', '<leader>aus', function()
    local RFile = require('related_files.file')
    local rfile = RFile:new()
    local uri = get_module_uri(rfile)
    local ut = "rake ut[" .. uri

    local tags, test_case_line_nr = find_test_case_tags()
    if tags then
        ut = ut .. "," .. table.concat(tags, ":")
    end

    ut = ut .. "]"

    local sections = find_sections_around_cursor(test_case_line_nr)
    if sections then
        ut = ut .. " -- --section-filter-exact \"" .. table.concat(sections, ":") .. "\""
    end

    print("ut: " .. ut)

    -- local linewise = ""
    vim.fn.setreg('"', ut, "l")
    vim.fn.setreg('+', ut)
end, {
    desc = "Create unit test command for the unit test TEST_CASE and SECTION for the cursor position/line"
})



-- ## NOTES ##

-- local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1]
-- L("line: ", line)
-- rfile.name: : "Process"
-- rfile.parent: : "/home/emile/repos/root-all/fusion/a3denc/"
-- rfile.namespace: : "auro/a3denc/v1/task/cx/pca/"
-- rfile.path: : "/home/emile/repos/root-all/fusion/a3denc/test/protected/auro/a3denc/v1/task/cx/pca/Process_tests.cpp"
-- rake ut[fusion/a3denc/v1/protected]


-- rfile.name: : "std"
-- rfile.parent: : "/home/emile/repos/root-all/core/std/"
-- rfile.namespace: : "auro/"
-- rfile.path: : "/home/emile/repos/root-all/core/std/test/cpp20/public/auro/std_tests.cpp"
-- rake ut[core/std/public]

-- ### Issues
--
-- doesn't work for ut in file: comp/cx/iec61937-15/test/public/auro/iec61937_15/MaxkbpsTable_tests.cpp

-- Idea:
--   * from the parent, find the parent git dir
--   * use the dirs from the parent to it's parent git dir as base
