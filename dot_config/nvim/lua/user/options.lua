vim.g.mapleader = ' '

-- support embedded lua and python
vim.g.vimsyn_embed = 'lP'

vim.opt.spelllang = 'en_us,nl'
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.mouse = 'a'
vim.opt.number = true
-- vim.opt.relativenumber = true
vim.opt.showmode = false -- prints e.g. INSERT in statusline, but already shown by lualine
vim.opt.encoding = 'utf-8'
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 5
vim.opt.cursorline = true
vim.opt.autowriteall = true
vim.opt.matchpairs:append('<:>')
vim.opt.inccommand = 'split'
vim.opt.signcolumn = 'yes'
vim.opt.foldlevelstart = 99
-- vim.opt.formatoptions['o'] = false -- don't automatically insert a comment when useing normal o or O on a comment line
-- the ebove options is e.g. reset in /usr/share/nvim/runtime/ftplugin/lua.vim

local cache_dir = vim.fn.stdpath('data') .. '/cache'

-- swapfiles can be useful (TODO: are they?),
-- however I don't want them in my working tree
vim.opt.directory = cache_dir .. '/swp'

vim.opt.undofile = true
vim.opt.undodir = cache_dir .. '/undo'

-- Tabwidth
vim.g.ruby_recommended_style = 0 -- Prevent vim from overwriting these settings when loading a ruby file, might be better to use after/ftplugin/ruby for this?
local tabwidth = 4
vim.opt.tabstop = tabwidth
vim.opt.shiftwidth = tabwidth
vim.opt.softtabstop = tabwidth
vim.opt.expandtab = true -- insert spaces on pressing `tab`

vim.opt.breakindent = true -- Indents word-wrapped lines as much as the 'parent' line
vim.opt.breakindentopt = 'sbr' -- display showbreak before additional indent of breakindent
vim.opt.showbreak = "◺   " -- String put at the start of lines that have been wrapped
-- vim.opt.showbreak = "↳   " -- String put at the start of lines that have been wrapped
-- vim.opt.showbreak = "↳.. " -- String put at the start of lines that have been wrapped
-- vim.opt.formatoptions:append('l') -- Dont autowrap in insert mode (TODO: maybe not want this? this is set by some built in ftplugins)
vim.opt.linebreak = true -- wrap but dont break words

-- TODO: not sure I want these
vim.opt.ignorecase = true
-- smartcase only has effect if ignorecase = true
vim.opt.smartcase = true
vim.opt.confirm = false
vim.opt.visualbell = true
vim.opt.wildignore = { '*/.ccls-cache/*', '*/tags' }

-- TODO: should first experiment with these to see if I need them
-- vim.opt.timeout = false
-- vim.opt.timeoutlen = 200
-- vim.opt.viminfo= "!,'1000,<1000,s100,h"
-- set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

-- defaults:
--(Vim default for
--   Win32:  !,'100,<50,s10,h,rA:,rB:
--   others: !,'100,<50,s10,h
-- Vi default: "")
-- e.g. try
-- :lua print(vim.inspect(vim.opt.shada:get()))
-- :lua vim.opt.shada:append()
-- :h sd (to get help about what is what)
local nr_old_files = 10000
local max_nr_lines_per_register = 500
local max_kib_size_per_item = 100
vim.opt.shada = {
    "!",
    "'" .. nr_old_files,
    "<" .. max_nr_lines_per_register,
    "s" .. max_kib_size_per_item,
    "h"
}


-- make formatting properly for comments with bullet lists
vim.opt.formatoptions:append('n')
vim.opt.formatlistpat:append('\\|^\\*\\s*')
vim.opt.formatlistpat:append('\\|^-\\s*')


vim.opt.textwidth = 120
-- draw line at textwidth
vim.opt.colorcolumn = '+1'
