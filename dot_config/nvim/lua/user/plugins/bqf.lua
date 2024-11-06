return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    disable = false,
    config = function()
        if IsNotAvailable('bqf') then return end
        require('bqf').setup({
            preview = {
                win_height = 25,
                winblend = 0
            }
        })
    end
}
