return {
    "monaqa/dial.nvim",
    config = function()
        vim.cmd([[
            nmap  <C-a>  <Plug>(dial-increment)
            nmap  <C-x>  <Plug>(dial-decrement)
            vmap  <C-a>  <Plug>(dial-increment)
            vmap  <C-x>  <Plug>(dial-decrement)
            vmap g<C-a> g<Plug>(dial-increment)
            vmap g<C-x> g<Plug>(dial-decrement)
            ]])

        local augend = require("dial.augend")
        require("dial.config").augends:register_group({
            default = {
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.date.alias["%Y/%m/%d"],
                augend.constant.alias.bool,
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,
            },
            -- typescript = {
            --     augend.integer.alias.decimal,
            --     augend.integer.alias.hex,
            --     augend.constant.new{ elements = {"let", "const"} },
            -- },
            visual = {
                augend.integer.alias.decimal,
                augend.integer.alias.hex,
                augend.date.alias["%Y/%m/%d"],
                augend.constant.alias.alpha,
                augend.constant.alias.Alpha,
            },
        })

        -- change augends in VISUAL mode
        -- vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_normal("visual"), {noremap = true})
        -- vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_normal("visual"), {noremap = true})
    end,
}
