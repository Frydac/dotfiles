---Operator function to invert comments on each line
function _G.__flip_flop_comment()
	local U = require("Comment.utils")
	local s = vim.api.nvim_buf_get_mark(0, "[")
	local e = vim.api.nvim_buf_get_mark(0, "]")
	local range = { srow = s[1], scol = s[2], erow = e[1], ecol = e[2] }
	local ctx = {
		ctype = U.ctype.linewise,
		range = range,
	}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)

	local rcom = {} -- ranges of commented lines
	local cl = s[1] -- current line
	local rs, re = nil, nil -- range start and end
	local lines = U.get_lines(range)
	for _, line in ipairs(lines) do
		if #line == 0 or not is_commented(line) then -- empty or uncommented line
			if rs ~= nil then
				table.insert(rcom, { rs, re })
				rs, re = nil, nil
			end
		else
			rs = rs or cl -- set range start if not set
			re = cl -- update range end
		end
		cl = cl + 1
	end
	if rs ~= nil then
		table.insert(rcom, { rs, re })
	end

	local cursor_position = vim.api.nvim_win_get_cursor(0)
	local vmark_start = vim.api.nvim_buf_get_mark(0, "<")
	local vmark_end = vim.api.nvim_buf_get_mark(0, ">")

	-- -Toggle comments on a range of lines
	-- -@param sl integer: starting line
	-- -@param el integer: ending line
	local toggle_lines = function(sl, el)
		vim.api.nvim_win_set_cursor(0, { sl, 0 }) -- idk why it's needed to prevent one-line ranges from being substituted with line under cursor
		vim.api.nvim_buf_set_mark(0, "[", sl, 0, {})
		vim.api.nvim_buf_set_mark(0, "]", el, 0, {})
		require("Comment.api").locked("toggle.linewise")("")
	end

	toggle_lines(s[1], e[1])
	for _, r in ipairs(rcom) do
		toggle_lines(r[1], r[2]) -- uncomment lines twice to remove previous comment
		toggle_lines(r[1], r[2])
	end

	vim.api.nvim_win_set_cursor(0, cursor_position)
	vim.api.nvim_buf_set_mark(0, "<", vmark_start[1], vmark_start[2], {})
	vim.api.nvim_buf_set_mark(0, ">", vmark_end[1], vmark_end[2], {})
	vim.o.operatorfunc = "v:lua.__flip_flop_comment" -- make it dot-repeatable
end

-- Invert (flip flop) comments with gC, in normal and visual mode
vim.keymap.set(
	{ "n", "x" },
	"gi",
	"<cmd>set operatorfunc=v:lua.__flip_flop_comment<cr>g@",
	{ silent = true, desc = "Invert comments" }
)


return {
    "numToStr/Comment.nvim",
    -- tag = "v0.6",
    config = function()
        if IsNotAvailable("Comment") then
            return
        end
        require("Comment").setup({
            ignore = '^$',
            ---LHS of toggle mappings in NORMAL + VISUAL mode
            ---@type table
            toggler = {
                ---line-comment keymap
                line = "<leader>c<leader>",
                ---block-comment keymap already has <leader>b to open buffers
                -- block = '<leader>bc',
            },

            ---LHS of operator-pending mappings in NORMAL + VISUAL mode
            ---@type table
            opleader = {
                ---line-comment keymap
                -- TODO: clashes with Lsp code action
                line = "<leader>c",
                ---block-comment keymap
                -- block = '<leader>b',
            },
            -- mappings = { extended = true },
        })

        -- TODO: make flip/flop comment
        -- local A = vim.api
        -- local U = require('Comment.utils')
        --
        -- function _G.__flip_flop_comment(vmode)
        --     local lcs, rcs = U.unwrap_cstr(vim.bo.commentstring)
        --     local scol, ecol, lines = U.get_lines(vmode, U.ctype.line)
        --
        --     local ll, rr = U.escape(lcs), U.escape(rcs)
        --     local padding = true
        --
        --     for i, line in ipairs(lines) do
        --         local is_commented = U.is_commented(line, ll, rr, padding)
        --         if is_commented then
        --             lines[i] = U.uncomment_str(line, ll, rr, padding)
        --         else
        --             lines[i] = U.comment_str(line, lcs, rcs, padding)
        --         end
        --     end
        --
        --     A.nvim_buf_set_lines(0, scol, ecol, false, lines)
        -- end
        --
        -- A.nvim_set_keymap('x', '<leader>l', '<ESC><CMD>lua __flip_flop_comment(vim.fn.visualmode())<CR>', { noremap = true, silent = true })




        -- vim.keymap.set("i", "<C-c>", function()
        --     vim.cmd('stopinsert')
        --     require("Comment.api").insert.blockwise.eol()
        -- end)
    end,
}
