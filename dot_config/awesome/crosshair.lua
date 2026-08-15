-- Shaped crosshair overlay.
--
-- Uses the X Shape extension via wibox.shape, so it needs no compositor:
-- only the crosshair pixels are mapped, there is no transparent background
-- to composite. Safe alongside anti-cheat -- it is an ordinary X window, not
-- an injected overlay.
--
-- Usage, in rc.lua:
--     local crosshair = require("crosshair")
--     -- then bind it, e.g. in globalkeys:
--     awful.key({ modkey }, "x", function() crosshair.toggle() end,
--               { description = "toggle crosshair", group = "awesome" }),

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local crosshair = {}

crosshair.config = {
    arm       = 7,          -- length of each arm, px
    gap       = 4,          -- empty space between centre and arm, px
    thickness = 2,          -- arm width, px
    dot       = 0,          -- centre dot size, px (0 disables)
    color     = "#00ff00",
    offset_y  = 0,          -- nudge if the game's centre is not the screen's
}

local box = nil

local function canvas_size()
    local c = crosshair.config
    return 2 * (c.gap + c.arm) + c.thickness
end

local function draw(cr, width, height)
    local c = crosshair.config
    local cx, cy = width / 2, height / 2
    local half = c.thickness / 2

    cr:rectangle(cx - c.gap - c.arm, cy - half, c.arm, c.thickness) -- left
    cr:rectangle(cx + c.gap,         cy - half, c.arm, c.thickness) -- right
    cr:rectangle(cx - half, cy - c.gap - c.arm, c.thickness, c.arm) -- up
    cr:rectangle(cx - half, cy + c.gap,         c.thickness, c.arm) -- down

    if c.dot > 0 then
        cr:rectangle(cx - c.dot / 2, cy - c.dot / 2, c.dot, c.dot)
    end
end

local function position(w, s)
    local g = s.geometry
    local size = canvas_size()
    w.x = g.x + math.floor((g.width  - size) / 2)
    w.y = g.y + math.floor((g.height - size) / 2) + crosshair.config.offset_y
end

local function build()
    local size = canvas_size()

    local w = wibox({
        width   = size,
        height  = size,
        bg      = crosshair.config.color,
        ontop   = true,
        type    = "dock",   -- keeps it above fullscreen clients
        visible = false,
        shape   = draw,
    })

    -- Let clicks through to the game underneath.
    w.input_passthrough = true

    return w
end

--- Rebuild the overlay after changing crosshair.config.
function crosshair.reload()
    local was_visible = box and box.visible
    if box then box.visible = false end
    box = build()
    if was_visible then crosshair.show() end
end

function crosshair.show()
    if not box then box = build() end
    position(box, awful.screen.focused())
    box.visible = true
    awesome.emit_signal("crosshair::toggled", true)
end

function crosshair.hide()
    if box then box.visible = false end
    awesome.emit_signal("crosshair::toggled", false)
end

--- True while the overlay is shown.
-- Lets rc.lua treat "crosshair up" as a proxy for "playing a game", e.g. to
-- stop the wibar floating above the window underneath it.
function crosshair.visible()
    return box ~= nil and box.visible == true
end

function crosshair.toggle()
    if crosshair.visible() then
        crosshair.hide()
    else
        crosshair.show()
    end
end

return crosshair
