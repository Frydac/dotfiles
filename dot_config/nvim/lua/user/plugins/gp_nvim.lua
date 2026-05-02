-- lazy.nvim
return {
    "robitx/gp.nvim",
    cmd = {
        "GpChatNew",
        "GpChatToggle",
        "GpChatFinder",
        "GpRewrite",
        "GpAppend",
        "GpPrepend",
        "GpEnew",
        "GpNew",
        "GpVnew",
        "GpTabnew",
        "GpPopup",
        "GpImplement",
    },
    config = function()
        local conf = {
            -- For customization, refer to Install > Configuration in the Documentation/Readme
            providers = {
                openai = {
                    endpoint = "https://api.openai.com/v1/chat/completions",
                    secret = { "cat", "/home/emile/linux_stuff/gpg/data/chat_gpt" }
                }
            }
        }
        require("gp").setup(conf)

        -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
}
