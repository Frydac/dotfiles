-- uses a character as colorcolumn iso 
-- vim.opt.colorcolumn = '+1' -- to enable
-- vim.opt.textwidth = 120
return {
    "lukas-reineke/virt-column.nvim",
    -- enabled = false,
    config = function()
        require("virt-column").setup()
    end,
}
