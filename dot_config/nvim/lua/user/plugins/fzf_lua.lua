return {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("fzf-lua").setup({
            winopts = {
                width = 0.9,
                height = 0.9,
                preview = {
                    horizontal = 'right:40%'
                }
            },
            fzf_opts = {
                -- prompt on bottom
                ['--layout'] = 'default'
            },
            oldfiles = {
                include_current_session = true
            }
        })
    end
}
