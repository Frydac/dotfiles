local M = {}

-- Only opt repositories with this editor init script into the Android setup.
function M.project_root(bufnr)
    local root = vim.fs.root(bufnr, { "settings.gradle", "settings.gradle.kts", "gradlew" })
    if root and vim.uv.fs_stat(root .. "/tools/jdtls-android.gradle") then
        return root
    end
end

function M.start(capabilities)
    local root = M.project_root(0)
    if not root then
        return
    end

    local jdtls = require("jdtls")
    local version = "1.64.0-202611091900"
    local server = vim.fn.stdpath("data") .. "/jdtls/" .. version .. "/bin/jdtls"
    local cache = vim.fn.stdpath("cache") .. "/jdtls/" .. version .. "/" .. vim.fn.sha256(root):sub(1, 16)
    if vim.fn.executable(server) ~= 1 then
        vim.notify("Missing JDT LS: " .. server, vim.log.levels.ERROR)
        return
    end
    vim.fn.mkdir(cache, "p")

    local config = {
        cmd = {
            server,
            "--java-executable",
            "/usr/lib/jvm/java-27-openjdk/bin/java",
            "--jvm-arg=-Xmx2g",
            "-configuration",
            cache .. "/config",
            "-data",
            cache .. "/workspace",
        },
        -- Gradle 7.5 must run on Java 17, independently of the server JVM.
        cmd_env = { JAVA_HOME = "/usr/lib/jvm/java-17-openjdk" },
        root_dir = root,
        capabilities = capabilities,
        settings = {
            java = {
                jdt = { ls = { androidSupport = { enabled = true } } },
                import = {
                    gradle = {
                        enabled = true,
                        wrapper = { enabled = true },
                        java = { home = "/usr/lib/jvm/java-17-openjdk" },
                        arguments = "--init-script tools/jdtls-android.gradle",
                    },
                },
                settings = { url = vim.uri_from_fname(root .. "/tools/jdtls.prefs") },
                configuration = {
                    updateBuildConfiguration = "automatic",
                    runtimes = {
                        { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk" },
                        { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk", default = true },
                    },
                },
            },
        },
        init_options = {
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
    }
    -- JDT LS reads these during initialize, before didChangeConfiguration.
    config.init_options.settings = config.settings
    config.init_options.workspaceFolders = { vim.uri_from_fname(root) }
    jdtls.start_or_attach(config)
end

function M.setup(capabilities)
    local group = vim.api.nvim_create_augroup("user-jdtls-android", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "java",
        callback = function()
            M.start(capabilities)
        end,
    })
    if vim.bo.filetype == "java" then
        M.start(capabilities)
    end
end

return M
