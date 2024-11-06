local M = {}

function M.notify_warning(msg)
    local ok, notify = pcall(require, 'notify')
    if ok then
        notify.notify(msg, vim.lsp.log_levels.WARN, { title = "Warning" })
    else
        vim.api.nvim_echo({{msg, "WarningMsg"}}, true, {})
    end
end

function M.notify_error(msg)
    local ok, notify = pcall(require, 'notify')
    if ok then
        notify.notify(msg, vim.lsp.log_levels.ERROR, { title = "Error" })
    else
        vim.api.nvim_echo({{msg, "ErrorMsg"}}, true, {})
    end
end

function M.notify_info(msg)
    local ok, notify = pcall(require, 'notify')
    if ok then
        notify.notify(msg, vim.lsp.log_levels.INFO, { title = "Info" })
    else
        vim.api.nvim_echo({{msg}}, true, {})
    end
end

return M
