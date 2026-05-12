--[[ Analog clock dial for sleep banner grid.
    Raster drawing adapted from clock.koplugin by jperon:
    https://github.com/jperon/clock.koplugin/blob/master/clockwidget.lua ]]
local Blitbuffer = require("ffi/blitbuffer")
local Geom = require("ui/geometry")
local Screen = require("device").screen
local Widget = require("ui/widget/widget")

local FrameStyle = require("banner.frame_style")

local M = {}

-- Weak-keyed scratch per rotated buffer lifetime (avoid in-place read/write races).
local rotate_scratch = setmetatable({}, { __mode = "k" })

local function rotate_bb(source, dest, center_x, center_y, angle_rad, only_color)
    local mw, mh = source:getWidth() - 1, source:getHeight() - 1
    local s, c = math.sin(angle_rad), math.cos(angle_rad)
    for x = 0, mw do
        for y = 0, mh do
            local rel_x = x - center_x
            local rel_y = y - center_y
            local old_x = math.floor(center_x + (rel_x * c - rel_y * s) + 0.5)
            local old_y = math.floor(center_y + (rel_x * s + rel_y * c) + 0.5)
            if old_x >= 0 and old_x <= mw and old_y >= 0 and old_y <= mh then
                local pixel = source:getPixel(old_x, old_y)
                if (not only_color) or pixel == only_color then
                    dest:setPixel(x, y, pixel)
                end
            end
        end
    end
end

local function rotate_into(bb, cx, cy, angle, only_color)
    local scratch = rotate_scratch[bb]
    if not scratch or scratch:getWidth() ~= bb:getWidth() or scratch:getHeight() ~= bb:getHeight() then
        if scratch then
            scratch:free()
        end
        scratch = Blitbuffer.new(bb:getWidth(), bb:getHeight(), bb:getType())
        rotate_scratch[bb] = scratch
    end
    -- Copy current bb state into scratch BEFORE rotating so unwritten pixels keep the
    -- existing background rather than zero (= COLOR_BLACK on most KOReader blitbuffers).
    scratch:blitFrom(bb, 0, 0, 0, 0, bb:getWidth(), bb:getHeight())
    rotate_bb(bb, scratch, cx, cy, angle, only_color)
    bb:blitFrom(scratch, 0, 0, 0, 0, scratch:getWidth(), scratch:getHeight())
end

local function paint_minute_tick(size, dest_bb, is_hour, stroke)
    local center = size / 2
    local tick_length = is_hour and size / 16 or size / 24
    local tick_width = is_hour and size / 66 or size / 100
    local x = math.floor(center - tick_width / 2)
    local y = math.floor(size * 0.05)
    local w = math.floor(tick_width)
    local h = math.floor(tick_length)
    dest_bb:paintRect(x, y, w, h, stroke)
end

local function draw_face(size, bb_type_, face_fill, stroke)
    local bb_type = bb_type_
    if not bb_type then
        bb_type = Screen.bb and Screen.bb:getType() or Blitbuffer.TYPE_BBRGB32
    end
    local bb = Blitbuffer.new(size, size, bb_type)
    bb:fill(face_fill)
    local center = size / 2
    local hour_angle = math.pi / 6
    local angle = math.pi / 30
    paint_minute_tick(size, bb, false, stroke)
    rotate_into(bb, center, center, angle, stroke)
    rotate_into(bb, center, center, angle, stroke)
    rotate_into(bb, center, center, 2 * angle, stroke)
    paint_minute_tick(size, bb, true, stroke)
    for hour = 1, 2 do
        rotate_into(bb, center, center, hour * hour_angle, stroke)
    end
    rotate_into(bb, center, center, hour_angle * 3, stroke)
    rotate_into(bb, center, center, hour_angle * 6, stroke)
    local radius = math.floor(size / 20)
    bb:paintCircle(center, center, radius, stroke)
    return bb
end

local function draw_hand(size, length_ratio, base_width_ratio, tip_width_ratio, bb_type, face_fill, stroke)
    local bb = Blitbuffer.new(size, size, bb_type)
    bb:fill(face_fill)
    local center = size / 2
    local hand_length = size * length_ratio
    local base_w = size * base_width_ratio
    local tip_w = size * tip_width_ratio
    local y_tip = center - hand_length
    local y_base = center
    for y = math.floor(y_tip), math.floor(y_base) do
        local denom = y_base - y_tip
        local progress = denom ~= 0 and (y - y_tip) / denom or 0
        local width = tip_w + (base_w - tip_w) * progress
        local left = center - width / 2
        bb:paintRect(math.floor(left), y, math.floor(width), 1, stroke)
    end
    local tip_r = math.floor(tip_w / 2)
    bb:paintCircle(math.floor(center), math.floor(y_tip), tip_r, stroke)
    return bb
end

local function bb_type_best()
    local sc = Screen.bb
    if sc ~= nil and type(sc.getType) == "function" then
        return sc:getType()
    end
    return Blitbuffer.TYPE_BBRGB32
end

-- Cache per size + palette; type differences handled in compose_hands_on_face via destination type.
local face_cache = {}
local hour_tpl_cache = {}
local min_tpl_cache = {}

local function palette_cache_key(size, face_fill, stroke)
    return string.format("%d|%s|%s", size, tostring(face_fill), tostring(stroke))
end

local function get_face(size, face_fill, stroke)
    local key = palette_cache_key(size, face_fill, stroke)
    local fb = face_cache[key]
    if not fb then
        fb = draw_face(size, bb_type_best(), face_fill, stroke)
        face_cache[key] = fb
    end
    return fb
end

local function get_hour_template(size, face_fill, stroke)
    local key = palette_cache_key(size, face_fill, stroke)
    local hh = hour_tpl_cache[key]
    if not hh then
        hh = draw_hand(size, 0.25, 1 / 18, 1 / 32, bb_type_best(), face_fill, stroke)
        hour_tpl_cache[key] = hh
    end
    return hh
end

local function get_minute_template(size, face_fill, stroke)
    local key = palette_cache_key(size, face_fill, stroke)
    local mm = min_tpl_cache[key]
    if not mm then
        mm = draw_hand(size, 0.35, 1 / 18, 1 / 32, bb_type_best(), face_fill, stroke)
        min_tpl_cache[key] = mm
    end
    return mm
end

local function compose_hands_on_face(size, hours, minutes, face_fill, stroke)
    local compose = Blitbuffer.new(size, size, bb_type_best())
    local face_bb = get_face(size, face_fill, stroke)
    compose:fill(face_fill)
    compose:blitFrom(face_bb, 0, 0, 0, 0, size, size)
    local center = size / 2
    local hour_rad = -math.pi / 6
    local minute_rad = -math.pi / 30
    local hh = get_hour_template(size, face_fill, stroke)
    local mh = get_minute_template(size, face_fill, stroke)
    rotate_bb(hh, compose, center, center, (hours + minutes / 60) * hour_rad, stroke)
    rotate_bb(mh, compose, center, center, minutes * minute_rad, stroke)
    return compose
end

local AnalogClock = Widget:extend{
    face_size = 96,
    face_fill = Blitbuffer.COLOR_WHITE,
    stroke = Blitbuffer.COLOR_BLACK,
}

function AnalogClock:init()
    local s = self.face_size
    self.dimen = Geom:new{ w = s, h = s }
end

function AnalogClock:paintTo(bb, px, py)
    local h = tonumber(os.date("%H"))
    local mi = tonumber(os.date("%M"))
    local composed = compose_hands_on_face(self.face_size, h, mi, self.face_fill, self.stroke)
    bb:blitFrom(composed, px, py, 0, 0, self.face_size, self.face_size)
    composed:free()
end

function M.register(Registry)
    Registry.register("clock_analog", function(params, ctx)
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        local pct = tonumber(params and params.diameter_pct) or 100
        pct = math.max(50, math.min(100, math.floor(pct)))
        local avail = math.min(ctx.cell_max_w, ctx.cell_max_h)
        local size = math.floor(avail * pct / 100)
        size = math.max(38, math.min(avail, size))
        if size % 2 == 1 then
            size = size - 1
        end
        return AnalogClock:new{
            face_size = size > 36 and size or 38,
            face_fill = pal.fill,
            stroke = pal.text_primary,
        }
    end)
end

return M
