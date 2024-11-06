

local function severity_to_str(severity)
    for k, v in pairs(vim.diagnostic.severity) do
        if v == severity then
            return string.format("%s - %s", k, v)
        end
        print("some new line")
    end
    return "Unknown vim.diagnostic.severity: " .. severity
end

local function format_ccls_diagnostic_result(diagnostic)
    local result = ""
    if diagnostic.source == "ccls"
        and diagnostic.user_data
        and diagnostic.user_data.lsp
        and diagnostic.user_data.lsp.relatedInformation then
        for index, extra_info in ipairs(diagnostic.user_data.lsp.relatedInformation) do
            if index > 1 then result = result .. "\n" end
            result = result .. string.format("%d:\n", index)
            result = result .. string.format(" * uri: %s:%d:%d\n",
                extra_info.location.uri,
                extra_info.location.range.start.line,
                extra_info.location.range.start.character)
            result = result .. string.format(" * msg: %s:\n",extra_info.message)
        end
        -- print("result: ", result)
    end
    return result
end

vim.diagnostic.config({
    virtual_text = {
        source = true,
        format = function(diagnostic)
            if diagnostic.user_data and diagnostic.user_data.code then
                return string.format('%s %s', diagnostic.user_data.code, diagnostic.message)
            else
                return diagnostic.message
            end
        end,
    },
    signs = false,
    float = {
        header = 'Diagnostics',
        source = false,
        border = 'rounded',
        format = function(diagnostic)
            local result = ""
            result = result .. string.format("message:  %s\n", diagnostic.message)
            result = result .. string.format("severity: %s\n", severity_to_str(diagnostic.severity))
            result = result .. string.format("source:   %s\n", diagnostic.source)
            result = result .. string.format("code:     %s\n", diagnostic.code)
            if diagnostic.source == "ccls" then
                result = result .. "ccls extra:\n"
                result = result .. format_ccls_diagnostic_result(diagnostic)
                -- result = result .. string.format("complete diagnostics table:\n%s", vim.inspect(diagnostic))
            else
                result = result .. "\n"
                result = result .. string.format("complete diagnostics table:\n%s", vim.inspect(diagnostic))
            end
            return result
        end
    },
})

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})


local ccls_test = {
    bufnr = 7,
    code = 2,
    col = 16,
    end_col = 40,
    end_lnum = 112,
    lnum = 112,
    message = "no matching function for call to 'from_adol'",
    namespace = 37,
    severity = 1,
    source = "ccls",
    user_data = {
        lsp = {
            code = 2,
            relatedInformation = { {
                location = {
                    range = {
                        end_ = {
                            character = 18,
                            line = 9
                        },
                        start = {
                            character = 9,
                            line = 9
                        }
                    },
                    uri = "file:///home/emile/repos/root-all/comp/codec/cpp14/protected/auro/codec/v3/adol/convert/encoder_version.hpp"
                },
                message = "candidate function not viable: no known conversion from 'const std::optional<adol::Instruction>' to 'const adol::Instruction' for 2nd argument"
            }, {
                location = {
                    range = {
                        end_ = {
                            character = 18,
                            line = 8
                        },
                        start = {
                            character = 9,
                            line = 8
                        }
                    },
                    uri = "file:///home/emile/repos/root-all/comp/codec/cpp14/protected/auro/codec/v3/adol/convert/auromatic.hpp"
                },
                message = "candidate function not viable: no known conversion from 'auro_codec_v3_metadata_EncoderVersion_t' to 'auro_codec_v3_metadata_Auromatic_t &' for 1st argument"
            }, {
                location = {
                    range = {
                        end_ = {
                            character = 18,
                            line = 11
                        },
                        start = {
                            character = 9,
                            line = 11
                        }
                    },
                    uri = "file:///home/emile/repos/root-all/comp/codec/cpp14/protected/auro/codec/v3/adol/convert/encoder_githash.hpp"
                },
                message = "candidate function not viable: no known conversion from 'auro_codec_v3_metadata_EncoderVersion_t' to 'Range<char *>' for 1st argument"
            }, {
                location = {
                    range = {
                        end_ = {
                            character = 18,
                            line = 31
                        },
                        start = {
                            character = 9,
                            line = 31
                        }
                    },
                    uri = "file:///home/emile/repos/root-all/comp/codec/cpp14/protected/auro/codec/v3/adol/convert/loudness.hpp"
                },
                message = "candidate function not viable: no known conversion from 'auro_codec_v3_metadata_EncoderVersion_t' to 'auro_codec_v3_metadata_Loudness_t &' for 1st argument"
            } }
        }
    }
}

-- format_ccls_diagnostic_result(ccls_test)

