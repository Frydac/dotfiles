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

local emi_util = require 'emi.util'
local capitalize = emi_util.string.capitalize
local upper_camel_case = emi_util.string.upper_camel_case
local Indent = emi_util.Indent

local function rfile_current_buffer()
    return RFile:new(util.current_buffer_fn())
end

local newline = t({ "", "" })
local nl = newline

local function open_modules(rfile, nodes, indent)
    for _, ns in ipairs(rfile.namespaces) do
        table.insert(nodes, t({ indent:get_inc() .. "module " .. capitalize(ns) }))
        table.insert(nodes, nl)
    end
end

local function close_modules(rfile, nodes, indent)
    for _, _ in ipairs(rfile.namespaces) do
        table.insert(nodes, nl)
        table.insert(nodes, t({ indent:get_dec() .. "end" }))
    end
end

local Snips = {}
Snips.init = {}

Snips.init.source_sn = function(rfile)
    local nodes = {}
    local indent = Indent:new()

    open_modules(rfile, nodes, indent)

    -- class
    table.insert(nodes, t({ indent:get_inc() .. "class " .. upper_camel_case(rfile.name) }))
    table.insert(nodes, nl)
    table.insert(nodes, t(indent:get()))
    table.insert(nodes, i(1))
    table.insert(nodes, nl)
    table.insert(nodes, t({ indent:get_dec() .. "end" }))

    close_modules(rfile, nodes, indent)
    return sn(1, nodes)
end

Snips.init.test_sn = function(rfile)
    local nodes = {}
    local indent = Indent:new()

    table.insert(nodes, t("require 'test/unit'"))
    table.insert(nodes, nl)
    table.insert(nodes, nl)

    -- class .. < TestCase
    local test_class_name = "Test"
    for _, ns in ipairs(rfile.namespaces) do
        test_class_name = test_class_name .. capitalize(ns)
    end
    test_class_name = test_class_name .. capitalize(rfile.name)
    table.insert(nodes, t("class " .. test_class_name .. " < Test::Unit::TestCase"))

    -- class body
    indent:increase()
    table.insert(nodes, nl)
    table.insert(nodes, t(indent:get() .. "def test_"))
    table.insert(nodes, i(1, "test_name"))
    table.insert(nodes, nl)
    table.insert(nodes, t({ indent:get() .. "end", "" }))
    indent:decrease()

    table.insert(nodes, t("end"))
    return sn(1, nodes)
end

Snips.init.script_sn = function()
end

Snips.init.release_sn = function()
    local nodes = {}
    local indent = Indent:new()
    local rfile = rfile_current_buffer()

    -- open_modules(rfile, nodes, indent)

    -- class
    -- table.insert(nodes, t({ indent:get_inc() .. "class " .. upper_camel_case(rfile.name) }))
    -- table.insert(nodes, nl)
    -- table.insert(nodes, t(indent:get()))
    -- table.insert(nodes, i(1))
    -- table.insert(nodes, nl)
    -- table.insert(nodes, t({ indent:get_dec() .. "end" }))

    -- close_modules(rfile, nodes, indent)
    return sn(1, nodes)
end

Snips.init.qc_sn = function()
    local nodes = fmt([[
        Build.register_qc('{} QC tests', :fast, {}) do |qc|
            qc.add_task{} do
                {}
            end
        end
    ]], {
        i(1, "description"), i(2, ":tags"),
        i(3, "(:tags)"),
        i(4)
    })

    return sn(1, nodes)
end

Snips.init.story_sn = function()
    local nodes = fmt([[
        namespace :story do
            task :test do
                {}
            end
        end
    ]],{
        i(1)
    })

    return sn(1, nodes)
end


function Snips.init_sn()
    return sn(1, {
        d(1, function()
            local rfile = rfile_current_buffer()
            if rfile.pargen_type.source then
                return Snips.init.source_sn(rfile)
            elseif rfile.pargen_type.test then
                return Snips.init.test_sn(rfile)
            elseif rfile.pargen_type.script then
                return sn(nil, t("initialization script script TODO!"))
            elseif rfile.pargen_type.release then
                return Snips.init.release_sn()
            elseif rfile.pargen_type.story then
                return Snips.init.story_sn()
            elseif rfile.pargen_type.qc then
                return Snips.init.qc_sn()
            else
                return sn(nil, t(vim.split(vim.inspect(rfile.pargen_type), "\n", {})))
            end
        end)
    })
end

M = {}

M.setup = function()
    ls.add_snippets("ruby", {
        s("init", Snips.init_sn()),
    })
end

-- print("adding ruby stuff")
ls.add_snippets("ruby", {
    s("init", Snips.init_sn()),
})

return M
