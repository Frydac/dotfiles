IsAvailable = function(module, do_log)
    if do_log == nil then do_log = true end -- explicitely set do_log to false
    local status, mod_mess = pcall(require, module)
    --if not status and M.do_log then require('emile.util').print_warning("Module not available or failed to load: "..module.."\n\nError:\n"..mod_mess) end
    if not status and do_log then
        -- print("Module not available or failed to load: "..module.."\n\nError:\n"..mod_mess)
        print("Module not available or failed to load: " .. module)
    end
    return status
end

IsNotAvailable = function(module)
    return not IsAvailable(module)
end

L = function(name, object)
    if object ~= nil then
        print(name .. ": " .. vim.inspect(object))
    else
        print(name .. ": nil")
    end
end
