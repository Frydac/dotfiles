
require('packer').startup(function(use)
    use {
        "EdenEast/nightfox.nvim",
        config = function ()
            require('nightfox').load('nightfox')
        end
}
end)
