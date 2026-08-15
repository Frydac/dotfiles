local spawn = require("awful.spawn")
local utils = require("awesome-wm-widgets.pactl-widget.utils")

local wpctl = {}


-- The setters take an optional callback, invoked once wpctl has exited. A
-- caller that refreshes its display needs this: wpctl is spawned
-- asynchronously, so reading the volume back straight away races the write and
-- returns the old value.
local function set_then(cmd, callback)
    spawn.easy_async(cmd, function()
        if callback then callback() end
    end)
end

function wpctl.volume_increase(device, step, callback)
    set_then('wpctl set-volume ' .. device .. ' ' .. step .. '%+', callback)
end

function wpctl.volume_decrease(device, step, callback)
    set_then('wpctl set-volume ' .. device .. ' ' .. step .. '%-', callback)
end

function wpctl.mute_toggle(device, callback)
    set_then('wpctl set-mute ' .. device .. ' toggle', callback)
end

function wpctl.get_volume_and_mute(device)
    local stdout = utils.popen_and_return('wpctl get-volume ' .. device)
    local vol = tonumber(string.match(stdout, "%d+%.%d+"))
    if vol ~= nil then
        vol = vol * 100
    end
    local mute = string.find(stdout, "MUTED") ~= nil
    return vol, mute
end

function wpctl.get_sinks_and_sources()
    local sinks = {}
    local sources = {}
    local in_section
    local in_subsection

    for line in utils.popen_and_return('wpctl status'):gmatch('[^\r\n]+') do
        in_section = string.match(line, "^%a+$") or in_section
        in_subsection = string.match(line, " (%a+):$") or in_subsection

        if in_section == "Audio" and (in_subsection == "Sinks" or in_subsection == "Sources") then
            local id, name = string.match(line, "   (%d+)%. ([%w- ]+)")
            if id and name then
                local is_default = string.find(line, "%*") ~= nil
                local device = { id = id, name = name, is_default = is_default }
                if in_subsection == "Sinks" then
                    table.insert(sinks, device)
                else
                    table.insert(sources, device)
                end
            end
        end
    end

    return sinks, sources
end

function wpctl.set_default(id)
    spawn('wpctl set-default ' .. id, false)
end


return wpctl
