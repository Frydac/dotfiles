local function reload(module)
    package.loaded[module] = nil
    require(module)
end

local function load_my_snippets()
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
    local rep = require('luasnip.extras').rep --repeat insert node text
    local events = require("luasnip.util.events")

    local lua = {}
    do
        lua.local_function = s("lf",
            {
                t("local function "), i(1, "name"), t("("), i(2, "opts"), t(")"),
                t({ "", "    " }), i(3),
                t({ "", "end" })
            })

        lua.func = s("f",
            {
                c(1, {
                    sn(nil, fmt([[function({}) {} end]], { i(1), i(2) })),
                    sn(nil, fmt([[
                function({})
                    {}
                end]], { i(1), i(2) })),
                })
            })
        lua.local_ = s("l", t("local "))

        lua.require = s("req", fmt("local {} = require('{}')", { i(1, "module"), rep(1) }))
        lua.for_ipairs = s("fori",
            fmt("for {}, {} in ipairs({})\n    {}\nend", { i(1, "index"), i(2, "value"), i(3, "table"), i(4) }))
        lua.for_pairs = s("forp",
            fmt("for {}, {} in pairs({})\n    {}\nend", { i(1, "index"), i(2, "value"), i(3, "table"), i(4) }))
    end

    -- local util = require("user.plugins.luasnip.util")

    -- local ri = function (insert_node_ids)
    --     return f(function (args) return args[1][1] end, insert_node_ids)
    -- end
    -- local file

    --     lua = {
    --         lua.local_function,
    --         lua.local_,
    --         lua.require,
    --         lua.for_ipairs,
    --         lua.for_pairs,
    --         lua.test
    --
    -- }
    -- ls.add_snippets("all", {
    --         s("trigger", fmt([[ something different {} , wut {} ]], { i(1, "text"),  rep(1) }))
    -- })

    -- remove all existing snippets -> for reloading config
    ls.cleanup()
    ls.add_snippets("all", {
        s("trig", fmt([[
                something 5 {} , wut {}
                insert visual selection here {}
            ]], { i(1, "text"), rep(1), f(function(args, snip) return snip.env.SELECT_RAW end, {}) }))
    })

    ls.add_snippets("lua", {
        lua.local_function,
        lua.func,
        lua.local_,
        lua.require,
        lua.for_ipairs,
        lua.for_pairs,
        s("emile", t("testing")),
        s("fu", fmt([[
            function {}.{}({})
                {}
            end]], { i(1, "Table"), i(2, "func_name"), i(3, "param"), i(0) }))
    })

    require('user.plugins.luasnip.cpp').setup()
    require('user.plugins.luasnip.ruby').setup()

end

local setup = function()
    local function prequire(...)
        local status, lib = pcall(require, ...)
        if (status) then return lib end
        return nil
    end

    local luasnip = prequire('luasnip')
    if not luasnip then
        print("Error: luasnip failed to require (luansip.init.lua)")
        return
    end
    local cmp = prequire("cmp")
    if not cmp then
        print("Error: cmp failed to require (luansip.init.lua)")
        return
    end

    local term = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end

    local feedkeys = function(str)
        -- "n" means noremap, which is important if you want to feedkeys back to vim after
        -- mapping to them, i.e. to avoid infinite recursion
        vim.api.nvim_feedkeys(term(str), "n", false)
    end

    local check_back_space = function()
        local col = vim.fn.col('.') - 1
        if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
            return true
        else
            return false
        end
    end

    local types = require("luasnip.util.types")

    luasnip.config.setup({
        -- store_selection_keys="<Tab>"
        store_selection_keys = "<c-j>",
        -- remember last snippet, can jump back into it later
        history = false,
        -- Update (e.g. rep() snippets) as you type
        update_events = "TextChanged,TextChangedI",

        -- no idea
        enable_autosnippets = false,

        ext_opts = {
            [types.choiceNode] = {
                passive = { virt_text = { { '⚟', 'Comment' } }, },
                active = { virt_text = { { '⚟', 'WarningMsg' } }, },
            },
            [types.insertNode] = {
                passive = { virt_text = { { '●', 'Comment' } }, },
                active = { virt_text = { { '●', 'WarningMsg' } } },
            }
        }
        -- ext_opts = {
        --     [types.choiceNode] = {
        --         active = {
        --             virt_text = { { "<-", "Comment" } },
        --         },
        --     },
        -- },
    })

    _G.tab_complete = function()
        if cmp and cmp.visible() then
            cmp.select_next_item()
        elseif luasnip and luasnip.expand_or_jumpable() then
            return term("<Plug>luasnip-expand-or-jump")
        elseif check_back_space() then
            return term "<Tab>"
        else
            cmp.complete()
        end
        return ""
    end
    _G.s_tab_complete = function()
        if cmp and cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip and luasnip.jumpable(-1) then
            return term("<Plug>luasnip-jump-prev")
        else
            return term "<S-Tab>"
        end
        return ""
    end

    _G.luasnip_expand_or_jump_or_fallthrough = function()
        if luasnip and luasnip.expand_or_jumpable() then
            return term("<Plug>luasnip-expand-or-jump")
        else
            return term("<c-j>")
        end
    end


    -- vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
    -- vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
    -- vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    -- vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    -- vim.api.nvim_set_keymap("i", "<c-j>", "<Plug>luasnip-expand-or-jump", {})
    -- vim.api.nvim_set_keymap("i", "<c-j>", "v:lua.luasnip_expand_or_jump_or_fallthrough()", {expr = true}) th
    -- vim.api.nvim_set_keymap("i", "<c-h>", "<Plug>luasnip-jump-prev", {})
    -- vim.api.nvim_set_keymap("s", "<c-h>", "<Plug>luasnip-jump-prev", {})
    -- vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>luasnip-next-choice", {})
    -- vim.api.nvim_set_keymap("s", "<C-l>", "<Plug>luasnip-next-choice", {})

    vim.keymap.set({ "i", "s" }, "<c-j>", function()
        if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            feedkeys("<c-j>")
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<c-h>", function()
        if luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            feedkeys("<c-h>")
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<c-l>", function()
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        else
            feedkeys("<c-l>")
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<c-;>", function()
        if luasnip.choice_active() then
            luasnip.change_choice(-1)
        else
            feedkeys("<c-;>")
        end
    end, { silent = true })


    -- TODO: add keymap for <cmd>LuasnipUnlinkCurrent

    load_my_snippets()
    -- require('emile.plugins.luasnip.choice_list_popup').setup()
end

return {
    "L3MON4D3/LuaSnip",
    config = function()
        setup()
    end,
}
