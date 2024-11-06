return {
    "windwp/nvim-autopairs",
    even = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup()
        -- npairs.add_rules(require('nvim-autopairs.rules.endwise-lua'))
        -- npairs.add_rules(require('nvim-autopairs.rules.endwise-elixir'))
        local npairs = require("nvim-autopairs")
        local Rule = require("nvim-autopairs.rule")

        -- Add spaces between parenthesis, e.g. [|] -> space -> [ | ]
        npairs.add_rules({
            Rule(" ", " "):with_pair(function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({ "()", "[]", "{}" }, pair)
            end),
        })
        -- npairs.add_rules(require('nvim-autopairs.rules.endwise-ruby'))

        if IsAvailable("cmp") then
            -- If you want insert `(` after select function or method item
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

            -- add a lisp filetype (wrap my-function), FYI: Hardcoded = { "clojure", "clojurescript", "fennel", "janet" }
            -- cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"
        end
    end,
}
