-- Commands: :PiAsk, :PiAskSelection, :PiCancel, :PiLog
return {
    "pablopunk/pi.nvim",
    config = function()
        require("pi").setup({
            provider = "openai-codex",
            model = "gpt-5.6-sol",
            thinking = "low",
            extensions = false,
            skills = false,
        })
    end
}
