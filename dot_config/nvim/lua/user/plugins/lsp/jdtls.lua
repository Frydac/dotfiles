local jdtls = require('jdtls')
local home = os.getenv('HOME')

-- Path to your Android SDK
local android_sdk = home .. '/Android/Sdk'

-- Path to the ExoPlayer demo root (adjust based on your clone location)
local project_root = vim.fn.getcwd() -- or hardcode like '/path/to/ExoPlayer/demos/main'

-- jdtls binary path (installed via Mason)
local jdtls_path = home .. '/.local/share/nvim/mason/packages/jdtls'
local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

-- Configuration
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher,
    '-configuration', jdtls_path .. '/config_linux', -- Use config_mac or config_win if on macOS/Windows
    '-data', home .. '/.cache/jdtls/workspace' .. vim.fn.fnamemodify(project_root, ':p:h:t'),
  },
  root_dir = project_root, -- Or use jdtls.setup.find_root({'gradlew', '.git', 'build.gradle'}),

  settings = {
    java = {
      home = '/usr/lib/jvm/java-17-openjdk', -- Your Java 17 path
      autobuild = { enabled = true },
      import = {
        gradle = { enabled = true }, -- Enable Gradle support
        maven = { enabled = false }, -- Disable Maven if not needed
      },
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-17',
            path = '/usr/lib/jvm/java-17-openjdk',
          },
        },
      },
    },
  },

  -- Extend classpath for Android SDK and ExoPlayer dependencies
  init_options = {
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    bundles = {}, -- Add Lombok or other bundles if needed
  },

  on_attach = function(client, bufnr)
    -- Enable standard LSP features
    require('jdtls.setup').add_commands()
    jdtls.setup_dap() -- Optional: for debugging
    print('jdtls attached to buffer')
  end,
}

-- Add Android SDK classpath (platform and libraries)
local android_jars = {
  android_sdk .. '/platforms/android-34/android.jar', -- Adjust android-XX based on your SDK
}
config.cmd[#config.cmd + 1] = '-cp'
config.cmd[#config.cmd + 1] = table.concat(android_jars, ':')

-- Start jdtls
jdtls.start_or_attach(config)
