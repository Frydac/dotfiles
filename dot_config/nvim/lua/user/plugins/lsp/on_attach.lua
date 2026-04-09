local M = {}

local augroup = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true })

local function set_default_and_clipboard(text, regtype)
    regtype = regtype or "v"

    vim.fn.setreg('"', text, regtype)

    local clipboard = vim.o.clipboard
    if clipboard:find("unnamedplus") then
        vim.fn.setreg("+", text, regtype)
    end
    if clipboard:find("unnamed") then
        vim.fn.setreg("*", text, regtype)
    end
end

local function symbol_info_handler(err, result)
    if err then
        vim.notify("Error lsp request 'textDocument/symbolInfo': " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    if not result or #result == 0 then
        vim.notify("No symbol info under cursor", vim.log.levels.INFO)
        return
    end

    local item = result[1]
    local full_name = (item.containerName or "") .. (item.name or "")

    set_default_and_clipboard(full_name, "v")
    vim.notify("Copied: " .. full_name, vim.log.levels.INFO)
end

local function lsp_copy_full_symbolname(bufnr)
    vim.lsp.buf_request(bufnr, "textDocument/symbolInfo", {
        textDocument = { uri = vim.uri_from_bufnr(bufnr) },
        position = vim.lsp.util.make_position_params(0).position,
    }, symbol_info_handler)
end

local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.on_attach(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local methods = vim.lsp.protocol.Methods

    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    map("n", "<leader><BS>", vim.lsp.buf.definition, opts)
    map("n", "<leader><leader><BS>", vim.lsp.buf.declaration, opts)
    map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    map("n", "<space>ac", vim.lsp.buf.code_action, opts)
    map("n", "<leader>oq", function()
        vim.lsp.buf.code_action({
            apply = true,
            context = {
                only = { "quickfix" },
            },
        })
    end, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<BS>e", function()
        vim.diagnostic.open_float(nil, { scope = "line" })
    end, opts)
    map("n", "[g", vim.diagnostic.goto_prev, opts)
    map("n", "]g", vim.diagnostic.goto_next, opts)
    map("n", "<BS>l", vim.diagnostic.setloclist, opts)
    map("n", "<BS>f", function()
        vim.lsp.buf.format({ async = true })
    end, opts)
    map("v", "<BS>f", function()
        vim.lsp.buf.format({ async = true })
    end, opts)
    map("n", "<space>D", vim.lsp.buf.type_definition, opts)
    map("n", "<BS>gt", vim.lsp.buf.type_definition, opts)
    map("n", "<BS>gi", vim.lsp.buf.implementation, opts)
    map("n", "<BS>gr", vim.lsp.buf.references, opts)
    map("n", "<BS>rn", vim.lsp.buf.rename, opts)
    map("n", "<BS>rs", function()
        for _, attached_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            attached_client:stop()
        end
    end, opts)

    if client:supports_method(methods.textDocument_signatureHelp) then
        map("n", "<M-s>", vim.lsp.buf.signature_help, opts)
        map("i", "<M-s>", vim.lsp.buf.signature_help, opts)
    end

    if client:supports_method("textDocument/symbolInfo") then
        map("n", "<BS>k", function()
            lsp_copy_full_symbolname(bufnr)
        end, opts)
    end

    if IsAvailable("lsp-inlayhints") then
        require("lsp-inlayhints").on_attach(client, bufnr)
    end

    if client:supports_method(methods.textDocument_inlayHint) then
        map("n", "<BS>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
        end, { noremap = true, silent = true, buffer = bufnr, desc = "[t]oggle inlay [h]ints" })
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup,
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client then
                M.on_attach(client, args.buf)
            end
        end,
    })
end

return M
