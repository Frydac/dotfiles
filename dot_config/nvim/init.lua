require('user.globals')
require('user.options')
require('user.keymaps').setup()
require('user.autocommands')

-- plugin manager
require('user.lazy')

-- depends on plenary being loaded
require('user.change_cwd')

require('user.find_where_included')
require('user.diagnostics')
