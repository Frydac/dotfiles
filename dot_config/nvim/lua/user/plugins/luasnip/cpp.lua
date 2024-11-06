if IsNotAvailable('luasnip') then return end

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep
local events = require("luasnip.util.events")

local util = require("user.plugins.luasnip.util").util
local RFile = require('related_files.file')

-- newline
local function nl()
    return t({ "", "" })
end

local function rfile_current_buffer()
    return RFile:new(util.current_buffer_fn())
end

-- TODO: make string extension with these functions?
local function ends_with(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

local function create_include(rfile)
    if rfile.pargen_type.h or rfile.pargen_type.c then
        return "#include <" .. rfile.namespace .. rfile.name .. ".h>"
    elseif rfile.pargen_type.hpp then
        return "#include <" .. rfile.namespace .. rfile.basename .. ">"
    elseif rfile.pargen_type.cpp or rfile.pargen_type.test then
        -- if a related C header exists and no related cpp header -> then return .h include
        -- in all other cases return .hpp include
        local header_relation_index = 1
        local existing_related_headers = rfile:find_existing_related_filenames(header_relation_index, true)
        if existing_related_headers then
            local is_hpp = false
            for _, header_fn in ipairs(existing_related_headers) do
                if ends_with(header_fn, "hpp") then
                    is_hpp = true
                end
            end
            if not is_hpp then
                return "#include <" .. rfile.namespace .. rfile.name .. ".h>"
            end
        end
        return "#include <" .. rfile.namespace .. rfile.name .. ".hpp>"
    elseif rfile.pargen_type.hpp then
        return "#include <" .. rfile.namespace .. rfile.name .. ".hpp>"
    else
        return "not implemented"
    end
end

local Snips = {}

Snips.include_guard = {
    name = function(rfile)
        rfile = rfile or rfile_current_buffer()
        local ig_name = "HEADER_"
        if rfile.namespaces then
            for _, ns in ipairs(rfile.namespaces) do
                ig_name = ig_name .. ns .. "_"
            end
        end
        ig_name = ig_name .. rfile.name .. "_" .. rfile.ext .. "_ALREADY_INCLUDED"
        ig_name = ig_name:gsub("[-.]", "_")
        return ig_name
    end,

    open = function(rfile)
        rfile = rfile or rfile_current_buffer()
        local ig_name = Snips.include_guard.name(rfile)
        return {
            "#ifndef " .. ig_name,
            "#define " .. ig_name
        }
    end,

    open_t = function(rfile)
        rfile = rfile or rfile_current_buffer()
        return t(Snips.include_guard.open(rfile))
    end,

    close = function()
        return t({ "#endif" })
    end,
}

Snips.include_header = function()
    return d(1, function()
        local rfile = rfile_current_buffer()
        return sn(1, t({ create_include(rfile) }))
    end)
end
function Snips.copyright_notice(pos, rfile)
    local crn = string.format([[/**************************************************************************
 * Name: %s
 *
 *  Copyright %d Auro Technologies. All Rights Reserved. Auro-3D and 
 *  the related symbols are registered trademarks of Auro Technologies. 
 *  All materials and technology contained in this work are protected 
 *  by copyright law and may not be reproduced, distributed, transmitted, 
 *  displayed, published or broadcast, in whole or in part, without the 
 *  prior written permission of Auro Technologies NV or in the case of 
 *  third party materials, the owner of that content, file and/or method. 
 *  You may not alter or remove any trademark, copyright or other notice 
 *  from copies of the content, file and/or method. All other referenced 
 *  marks are those of their respective owners.
 *  
 *  Auro Technologies, phone +32-(0)-14314343, fax +32-(0)-14321224, 
 *  www.auro-technologies.com, info@auro-technologies.com.
 * 
 *************************************************************************/
 ]]  ,
        rfile.namespace .. rfile.basename,
        os.date("%Y"))

    rfile = rfile or rfile_current_buffer()
    local lines = vim.split(crn, "\n")
    local line_text_nodes = {}
    for ix_, line in pairs(lines) do
        local text_node = {}
        if ix_ ~= #lines then
            table.insert(text_node, "")
        end
        table.insert(text_node, line)
        table.insert(line_text_nodes, t(text_node))
    end
    return sn(pos, line_text_nodes);
end

local function create_c_namespace(rfile)
    rfile = rfile or rfile_current_buffer()
    return table.concat(rfile.namespaces, "_")
end

local function create_cpp_namespace(rfile)
    rfile = rfile or rfile_current_buffer()
    return table.concat(rfile.namespaces, "::")
end

local function create_c_struct_basename(rfile)
    rfile = rfile or rfile_current_buffer()
    return create_c_namespace(rfile) .. "_" .. rfile.name .. "_"
end

function Snips.c_struct_sn(pos, rfile)
    rfile = rfile or rfile_current_buffer()
    local c_struct_basename = create_c_struct_basename(rfile)
    return sn(
        pos,
        fmt([[
            typedef struct {basename}{type}
            {{
                {last}
            }} {type_with_t}
        ]], {
            basename = f(function() return c_struct_basename end, {}),
            type = i(1, "Type_"),
            last = i(2),
            type_with_t = f(function(args) return c_struct_basename .. args[1][1] .. "t;" end, { 1 })
        })
    )
end

function Snips.c_struct()
    return s(
        { trig = "cstr?u?c?t?", regTrig = true },
        d(1, function() return Snips.c_struct_sn() end)
    )
end

function Snips.c_enum_sn(pos, rfile)
    rfile = rfile or rfile_current_buffer()
    local c_struct_basename = create_c_struct_basename(rfile)
    return sn(
        pos,
        fmt([[
            typedef enum
            {{
                {last}
            }} {basename}{type}_t;
        ]], {
            basename = f(function() return c_struct_basename end, {}),
            type = i(1, "Type"),
            last = i(2)
        })
    )
end

function Snips.c_enum()
    return s(
        { trig = "cenu?m?", regTrig = true },
        d(1, function() return Snips.c_enum_sn() end)
    )
end

function Snips.cpp_class_sn(pos, rfile)
    rfile = rfile or rfile_current_buffer()
    return sn(
        pos,
        fmt([[
            class {}
            {{
                {}
            }};
        ]], {
            f(function() return rfile.name end, {}),
            i(1)
        })
    )
end

-- Indent each line of passed snippet node
local function indent_sn(sn_to_indent, indent)
    return isn(
        1, {
            t({ indent }),
            sn_to_indent
        },
        indent
    )
end

function Snips.cpp_class()
    return s(
        { trig = "clas?s?", regTrig = true },
        Snips.cpp_class_sn(1)
    )
end

local function cpp14_namespace_open(namespaces)
    local result = ""
    for ix, ns in ipairs(namespaces) do
        result = result .. "namespace " .. ns .. " {"
        if ix ~= #namespaces then
            result = result .. " "
        end
    end
    return result
end

local function cpp17_namespace_open(namespaces)
    local result = "namespace " .. table.concat(namespaces, "::") .. " {"
    return result
end

local function cpp_namespace_open(namespaces, is_cpp17)
    if is_cpp17 then
        return cpp17_namespace_open(namespaces)
    else
        return cpp14_namespace_open(namespaces)
    end
end

local function cpp14_namespace_close(namespaces)
    local result = ""
    for _ = 1, #namespaces do
        result = result .. "}"
        -- if ix ~= #namespaces then
        --     result = result .. " "
        -- end
    end
    return result
end

local function cpp17_namespace_close(namespaces)
    return "}"
end

function Snips.cpp14_namespace_sn(pos, rfile)
    rfile = rfile or rfile_current_buffer()
    local namespaces = rfile.namespaces
    return sn(
        pos,
        fmt([[
            {ns_open}
                {indent_visual_block}
            {ns_close}
        ]], {
            ns_open = f(function() return cpp14_namespace_open(namespaces) end),
            indent_visual_block = util.iv(1, 4),
            ns_close = f(function() return cpp14_namespace_close(namespaces) end)
        })
    )
end

local function cpp_namespace_close(namespaces, is_cpp17)
    if is_cpp17 then
        return cpp17_namespace_close(namespaces)
    else
        return cpp14_namespace_close(namespaces)
    end
end

function Snips.cpp14_namespace()
    return s(
        { trig = "ns4?", regTrig = true },
        { d(1, function() return Snips.cpp14_namespace_sn(1) end) }
    )
end

function Snips.cpp17_namespace_sn(pos, rfile)
    rfile = rfile or rfile_current_buffer()
    local namespaces = rfile.namespaces
    return sn(
        pos,
        fmt([[
            {ns_open}
                {indent_visual_block}
            }}
        ]], {
            ns_open = f(function() return cpp17_namespace_open(namespaces) end),
            indent_visual_block = util.iv(1, 4),
        })
    )
end

function Snips.cpp17_namespace()
    return s(
        { trig = "ns7?", regTrig = true },
        { d(1, function() return Snips.cpp17_namespace_sn(1) end) }
    )
end

function Snips.namespaces_using_sn(pos, namespaces)
    return sn(pos,
        {
            t({ "using namespace " }),
            f(function()
                if #namespaces == 0 then return "" end
                local result = table.remove(namespaces, 1)
                for _, ns in ipairs(namespaces) do
                    result = result .. "::" .. ns
                end
                return result
            end),
            t({ ";" })
        }
    )
end

function Snips.namespaces_using_incremental_sn(rfile)
    rfile = rfile or rfile_current_buffer()
    local namespaces = rfile.namespaces
    local ns_ix = 1
    local recursive_sn
    recursive_sn = function()
        return sn(nil,
            {
                c(1, {
                    t({ "" }),
                    sn(nil, {
                        d(1, function()
                            ns_ix = ns_ix + 1
                            if (ns_ix <= #namespaces) then
                                local ns = "::" .. namespaces[ns_ix]
                                return sn(nil, { t({ ns }), d(1, recursive_sn, {}) })
                            else
                                return sn(nil, { t({ "" }) })
                            end
                        end)
                    })
                })
            }
        )
    end

    return sn(nil,
        { t({ "using namespace " }),
            f(function()
                if #namespaces > 1 then
                    return namespaces[1]
                else
                    return ""
                end
            end, {}),
            d(1, recursive_sn, {}), t({ ";", "" }), i(0) })
end

function Snips.namespaces_using()
    return s(
        {
            trig = "usn",
            name = "using namespace with incremental namespace suggestions",
        },
        { d(1, function() return Snips.namespaces_using_incremental_sn() end) }
    )
end

function Snips.namespace_c_style(rfile)

end

function Snips.c_style_enum(rfile)

end

function Snips.switch()
    return s(
        {
            trig = "swi?t?c?h?",
            regTrig = true
        },
        fmt([[
                switch ({})
                {{
                    {}
                }}
            ]],
            {
                i(1, ""), i(2)
            }
        )
    )
end

function Snips.switch_case3(pos)
    return sn(pos, fmt([[
        case {}:
            {}
        break;
    ]], { i(1, "value"), i(2) }))
end

function Snips.endl() return s("el", fmt([[std::endl{}]], { i(1, ";") })) end

function Snips.unsigned_int_sn(pos) return sn(pos, t("unsigned int")) end

function Snips.mss(c_or_cpp)
    local ts_utils = require("nvim-treesitter.ts_utils")
    local print_error = require('user.notify').notify_error

    -- TODO: only supports 1 line range, only needed for return type now
    local function get_range_from_buffer(start_row, start_column, end_row, end_column)
        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, true)
        if not lines then
            print_error("Can't get buffer lines containing the function return type")
            return nil
        end
        if #lines ~= 1 then
            print_error("The return type of the containing function is over more than one line")
            return nil
        end
        return lines[1]:sub(start_column + 1, end_column)
    end

    local function get_return_type_str(function_definition_node)
        for child_node in function_definition_node:iter_children() do
            if child_node:type() == "type_identifier"
                or child_node:type() == "primitive_type"
                or child_node:type() == "template_type"
                or child_node:type() == "qualified_identifier" -- optional<type> TODO: we should really know type as MSS_END needs it
            then
                local start_row, start_column, end_row, end_column = child_node:range()
                return get_range_from_buffer(start_row, start_column, end_row, end_column)
            end

        end
        return nil
    end

    local function get_return_type_pointer_or_reference_str(function_definition_node)
        for child_node in function_definition_node:iter_children() do
            if child_node:type() == "pointer_declarator" then return "*" end
            if child_node:type() == "reference_declarator" then return "&" end
        end
    end

    local function get_return_type_from_parent_function_at_cursor()
        local node = ts_utils.get_node_at_cursor()
        if not node then
            print_error("Can't get node at cursor")
            return nil
        end

        -- since some change the fucntion_definition changes to a declaration when typing MSS in the
        -- function body..
        while node:type() ~= "function_definition"
            and not ends_with(node:type(), "declaration") do
            node = node:parent()
            if not node then
                print_error("Can't get find parent node with type: 'function_definition'")
                return nil
            end
        end

        local return_type_str = get_return_type_str(node)
        if (return_type_str) then
            local return_type_ptr_or_ref_str = get_return_type_pointer_or_reference_str(node)
            if return_type_ptr_or_ref_str then
                return_type_str = return_type_str .. " " .. return_type_ptr_or_ref_str
            end
            return return_type_str
        else
            print_error("Can't find return type")
            return nil
        end
    end

    if (c_or_cpp == "cpp") then
        return s(
            {
                trig = "MS?S?",
                regTrig = true
            },
            fmt([[
                MSS_BEGIN({});
                {}{}
                MSS_END();
            ]],
                {
                    f(function()
                        local return_type_str = get_return_type_from_parent_function_at_cursor()
                        if return_type_str then
                            return return_type_str
                        else
                            return "bool"
                        end
                    end, {}),
                    util.iv(2, 0),
                    i(0)
                })
        )
    else
        return s(
            {
                trig = "MS?S?",
                regTrig = true
            },
            fmt([[
                MSS_BEGIN_{}();
                {}{}
                MSS_END_{}();
            ]],
                {
                    f(function()
                        local return_type_str = get_return_type_from_parent_function_at_cursor()
                        if return_type_str == "auro_ReturnCode_t" then
                            return "RC"
                        else
                            return "B"
                        end
                    end),
                    util.iv(2, 0),
                    i(0),
                    f(function()
                        local return_type_str = get_return_type_from_parent_function_at_cursor()
                        if return_type_str == "auro_ReturnCode_t" then
                            return "RC"
                        else
                            return "B"
                        end
                    end),
                }
            )
        )
    end
end

Snips.loop = {}

function Snips.loop.fora_sn(pos)
    return sn(pos, fmt([[
            for (auto {} = {}; {} != {}; ++{})
            {{
                {}
            }}
        ]], { i(1, "i"), i(2, "0u"), rep(1), i(3, "size"), rep(1), util.iv(4, 4) }))
end

function Snips.loop.forcr_sn(pos)
    return sn(pos, fmt([[
            for (const auto& {} : {})
            {{
                {}
            }}
        ]], { i(1, "element"), i(2, "container"), util.iv(3, 4) }))
end

function Snips.loop.forr_sn(pos)
    return sn(pos, fmt([[
            for (auto& {} : {})
            {{
                {}
            }}
        ]], { i(1, "element"), i(2, "container"), util.iv(3, 4) }))

end

function Snips.loop.forv_sn(pos)
    return sn(pos, fmt([[
            for (auto {} : {})
            {{
                {}
            }}
        ]], { i(1, "element"), i(2, "container"), util.iv(3, 4) }))

end

function Snips.loop.forst_sn(pos)
    return sn(pos, fmt([[
            for (std::size_t {} = {}; {} != {}, ++{})
            {{
                {}
            }}
        ]], { i(1, "i"), i(2, "0"), rep(1), i(3, "size"), rep(1), util.iv(4, 4) }))
end

-- support for C89
function Snips.loop.afor_sn(pos)
    return sn(pos, fmt([[
            AURO_FOR_BEGIN(int {} = 0, {} < {}, ++{})
            {{
                {}
            }}
            AURO_FOR_END()
        ]], { i(1, "i"), rep(1), i(2, "size"), rep(1), i(3) }))
end

function Snips.loop.for_choice_sn(pos)
    return sn(pos,
        {
            c(1, {
                Snips.loop.forcr_sn(),
                Snips.loop.forr_sn(),
                Snips.loop.forv_sn(),
                Snips.loop.fora_sn(),
                Snips.loop.forst_sn()
            })
        })
end

Snips.ifdef_cpp = {}
function Snips.ifdef_cpp.open(pos)
    return sn(pos, t({
        "#ifdef _cplusplus",
        "extern \"C\" {",
        "#endif",
        ""
    }))
end

function Snips.ifdef_cpp.close(pos)
    return sn(pos, t({
        "#ifdef __cplusplus",
        "}",
        "#endif",
        ""
    }))
end

Snips.test = {}

function Snips.test.section(pos)
    return sn(pos, fmt(
        [[
            SECTION("{}")
            {{
                {}
            }}
        ]],
        { i(1, "default"), util.iv(2, 4) }
    ))
end

function Snips.test.require()
    return sn(1, fmt([[REQUIRE({})]], { i(1) }))
end

function Snips.test.test_case(pos)
    return sn(pos, fmt(
        [[
            TEST_CASE_FAST("test {}{}", "{}{}")
            {{
                {}
            }}
        ]],
        {
            f(function()
                local rfile = rfile_current_buffer()
                -- TODO: check for matching header and use c-style when c header
                local result = create_cpp_namespace(rfile) .. "::" .. rfile.name
                return result
            end),
            i(1),
            f(function()
                local rfile = rfile_current_buffer()
                local result = ""
                if rfile.namespaces then
                    for _, ns in ipairs(rfile.namespaces) do
                        result = result .. "[" .. ns .. "]"
                    end
                end
                result = result .. "[" .. rfile.name .. "]"
                return result
            end),
            i(2),
            i(3)
        }
    ))
end

function Snips.init_c_header_sn(pos, pargen_type)
    return d(nil,
        function()
            local rfile = rfile_current_buffer()
            local nodes = {
                Snips.include_guard.open_t(rfile),
            }
            if pargen_type.public then
                table.insert(nodes, Snips.copyright_notice(1, rfile))
            end
            table.insert(nodes, Snips.ifdef_cpp_open())
            -- cstruct/cfunc
            table.insert(nodes, Snips.ifdef_cpp_close())
            table.insert(nodes, Snips.include_guard.close())
            return sn(nil, nodes)
        end
    )
end

PosCounter = {}

function PosCounter:new()
    local obj = {}
    obj.current_position = 0
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function PosCounter:next()
    self.current_position = self.current_position + 1
    return self.current_position
end

Snips.init = {}
Snips.init.c = {}
Snips.init.cpp = {}
Snips.init.test = {}

function Snips.init.c.header_sn(position, is_public)
    local pos = PosCounter:new()
    return sn(position, {
        d(1,
            function()
                local rfile = rfile_current_buffer()

                local nodes = {
                    Snips.include_guard.open_t(rfile),
                    nl(),
                }

                if is_public then
                    table.insert(nodes, Snips.copyright_notice(pos:next(), rfile))
                    table.insert(nodes, nl())
                    table.insert(nodes, nl())
                end

                table.insert(nodes, Snips.ifdef_cpp.open(pos:next()))
                table.insert(nodes, nl())

                -- cstruct/cfunc
                -- table.insert(nodes, i(pos:next(), "c_struct{}"))
                table.insert(nodes, Snips.c_struct_sn(pos:next(), rfile))
                table.insert(nodes, nl())
                table.insert(nodes, nl())

                table.insert(nodes, Snips.ifdef_cpp.close(pos:next()))
                table.insert(nodes, nl())

                table.insert(nodes, Snips.include_guard.close())
                table.insert(nodes, nl())
                return sn(1, nodes)
            end
        )
    }
    )
end

function Snips.init.c.source_sn(position, rfile)
    return sn(position, {
        d(1,
            function()
                rfile = rfile or rfile_current_buffer()
                local include_str = create_include(rfile)

                return sn(1, t({ include_str }))

            end)
    })
end

function Snips.init.cpp.header_sn(position, is_public, is_cpp17)
    local pos = PosCounter:new()
    return sn(position, {
        d(1,
            function()
                local rfile = rfile_current_buffer()

                local nodes = {
                    Snips.include_guard.open_t(rfile),
                    nl(),
                    nl()
                }

                if is_public then
                    table.insert(nodes, Snips.copyright_notice(pos:next(), rfile))
                    table.insert(nodes, nl())
                    table.insert(nodes, nl())
                end

                table.insert(nodes, f(function() return cpp_namespace_open(rfile.namespaces, is_cpp17) end))
                table.insert(nodes, nl())
                table.insert(nodes, nl())

                table.insert(nodes, indent_sn(Snips.cpp_class_sn(pos:next(), rfile), "    "))
                table.insert(nodes, nl())
                table.insert(nodes, nl())

                table.insert(nodes, f(function() return cpp_namespace_close(rfile.namespaces, is_cpp17) end))
                table.insert(nodes, nl())
                table.insert(nodes, nl())

                table.insert(nodes, Snips.include_guard.close())
                table.insert(nodes, nl())
                return sn(1, nodes)
            end
        )
    })
end

function Snips.init.cpp.source_sn(position, rfile, is_cpp17)
    return sn(position, {
        d(1,
            function()
                rfile = rfile or rfile_current_buffer()
                local include_str = create_include(rfile)

                return sn(1,
                    {
                        t({ include_str }),
                        nl(), nl(),
                        f(function() return cpp_namespace_open(rfile.namespaces, is_cpp17) end),
                        nl(), nl(),
                        i(1),
                        nl(), nl(),
                        f(function() return cpp_namespace_close(rfile.namespaces, is_cpp17) end)
                    }
                )
            end)
    })
end

function Snips.init.test.source_sn(position, rfile, is_cpp17)
    local pos = PosCounter:new()
    return sn(position, {
        d(1,
            function()
                rfile = rfile or rfile_current_buffer()
                local include_header_str = create_include(rfile)
                local nodes = {
                    t({ include_header_str }),
                    nl(),
                    t({ "#include <doctest.hpp>" }),
                    nl(), nl(),
                    d(pos:next(), function()
                        if #rfile.namespaces > 0 then
                            return Snips.namespaces_using_sn(1, { rfile.namespaces[1] })
                        else
                            return sn(nil, t({ "" }))
                        end
                    end),
                }

                if #rfile.namespaces > 1 then
                    table.insert(nodes, nl())
                    table.insert(nodes, Snips.namespaces_using_sn(pos:next(), rfile.namespaces))
                    table.insert(nodes, nl())
                    table.insert(nodes, i(pos:next()))
                end

                return sn(1, nodes)
            end)
    })
end

function Snips.init_sn()
    return sn(1, {
        d(1, function()
            local rfile = RFile:new(util.current_buffer_fn())
            local is_cpp17 = rfile.pargen_type.cpp17 or rfile.pargen_type.cpp20 or rfile.pargen_type.cpp23
            L("rfile.pargen_type: ", rfile.pargen_type)
            L("is_cpp17: ", is_cpp17)

            if rfile.pargen_type.h then
                return Snips.init.c.header_sn(1, rfile.pargen_type.public)
            elseif rfile.pargen_type.c then
                return Snips.init.c.source_sn(1, rfile)
            elseif rfile.pargen_type.hpp then
                return Snips.init.cpp.header_sn(1, rfile.pargen_type.public, is_cpp17)
            elseif rfile.pargen_type.cpp then
                return Snips.init.cpp.source_sn(1, rfile.pargen_type.public, is_cpp17)
            elseif rfile.pargen_type.test then
                return Snips.init.test.source_sn(1, rfile.pargen_type.public, is_cpp17)
            else
                return sn(nil, t(vim.split(vim.inspect(rfile.pargen_type), "\n")))
            end
        end)
    })
end

function Snips.do_log(pos)
    return sn(pos, fmt([[constexpr bool do_log{{{}}};]], { i(1, "true") }))
end

function Snips.do_log_namespace(pos)
    return sn(pos, fmt([[
        namespace {{
            constexpr bool do_log{{{}}};
        }}
        ]], { i(1, "true") }))
end

-- TODO: init _tests.cpp

M = {}
M.setup = function()

    ls.filetype_extend("cpp", { "c" })

    -- TODO: move to c.lua
    ls.add_snippets("c", {
        s("afor", Snips.loop.afor_sn()),
        s("ui", Snips.unsigned_int_sn(1)),
        s("init", Snips.init_sn()),
        s("inh", Snips.include_header()),

        s("c", f(function() return create_c_namespace(RFile:new(util.current_buffer_fn())) .. "_" end, {})),
        Snips.c_struct(),
        Snips.c_enum(),
        Snips.mss("c"),
    })

    ls.add_snippets("cpp", {
        s("dl", Snips.do_log()),
        s("ndl", Snips.do_log_namespace()),
        s("st", t("std::size_t")),
        s("ui", Snips.unsigned_int_sn(1)),
        Snips.endl(),
        s("co", t("std::cout << ")),
        s("s", t("std::")),
        s({
            trig = "i3?2?",
            regTrig = true
        }
            , t("std::int32_t")),
        s({
            trig = "i64?",
            regTrig = true
        }
            , t("std::int64_t")),

        s("for", Snips.loop.for_choice_sn(1)),
        s("fora", Snips.loop.fora_sn(1)),
        s("forcr", Snips.loop.forcr_sn(1)),
        s("forr", Snips.loop.forr_sn(1)),
        s("forv", Snips.loop.forv_sn(1)),
        s("forst", Snips.loop.forst_sn(1)),

        s("init", Snips.init_sn()),
        s("inh", Snips.include_header()),

        Snips.mss("cpp"),
        Snips.switch(),
        Snips.cpp14_namespace(),
        Snips.cpp17_namespace(),
        Snips.namespaces_using(),

        s("S", Snips.test.section(1)),
        s("R", Snips.test.require()),
        s("T", Snips.test.test_case(1)),

        -- s("case", Helpers.switch_case(1)),
        s("case", Snips.switch_case3(1)),

        s("inap", fmt([[#include <{}{}>]], { f(function() return util.namespace() end, {}), i(1) })),
        s("ina", fmt([[#include <auro/{}>]], { i(1) })),
        s("in", fmt([[#include <{}>]], { i(1, "vector") })),

        s("igo", { f(function() return Snips.include_guard.open() end) }),

        s("isn2", {
            isn(1, {
                t({ "    " }),
                sn(
                    1,
                    fmt([[
                        class {}
                        {{

                        }};
                    ]], {
                        f(function() return "test" end, {})
                    })
                )
            }, "----")
        }),

        s("isn1", {
            sn(1, {
                t({ "    " }),
                isn(1, t({ "// This is", "A multiline", "comment" }), "    ")
            })
        }),

        s("ex", t("exit(0);"));

        s(
            "crn",
            {
                d(1, function()
                    local rfile = RFile:new(util.current_buffer_fn())
                    return Snips.copyright_notice(1, rfile)
                end)
            }),
        s('test', { t("text2-"), i(1), t("- more text"), i(2) })

        -- s({"inap", "`include auro path`, based on the related files parser, create and include statement that already prints out the current file's namespace path"}, fmt([[#include <{}{}>]], { f(function() return util.namespace() end, {}), i(1) })),
    })

    -- ls.add_snippets("cpp", {
    --     s("S", fmt([[
    --     SECTION("{}")
    --     {{
    --         {}
    --     }}
    --     ]], { i(1, "default"), util.iv(2, 4) })),
    -- })
end

return M
