local Blitbuffer = require("ffi/blitbuffer")
local Device = require("device")
local Geom = require("ui/geometry")
local RenderText = require("ui/rendertext")
local Widget = require("ui/widget/widget")

local Screen = Device.screen

--- Battery body + tip drawn to BB; label centered inside inner area.
local BatteryGlyph = Widget:extend{
    capacity = 0,
    label = "",
    face = nil,
    fill_color = Blitbuffer.COLOR_BLACK,
    stroke_color = Blitbuffer.COLOR_BLACK,
    level_color = Blitbuffer.COLOR_GRAY,
    text_color = Blitbuffer.COLOR_BLACK,
    body_w = 120,
    body_h = 48,
    tip_w = 6,
    radius = 6,
    inner_pad = 4,
}

function BatteryGlyph:init()
    self.dimen = Geom:new{
        w = self.body_w + self.tip_w,
        h = self.body_h,
    }
end

function BatteryGlyph:getSize()
    return Geom:new{ x = 0, y = 0, w = self.dimen.w, h = self.dimen.h }
end

function BatteryGlyph:paintTo(bb, x, y)
    local bw, bh = self.body_w, self.body_h
    local cap = math.max(0, math.min(100, tonumber(self.capacity) or 0))
    local ix = x + self.inner_pad
    local iy = y + self.inner_pad
    local iw = bw - 2 * self.inner_pad
    local ih = bh - 2 * self.inner_pad
    local fill_w = math.floor(iw * cap / 100 + 0.5)
    bb:paintRoundedRect(x, y, bw, bh, self.level_color, self.radius)
    if fill_w > 0 then
        bb:paintRoundedRect(
            ix,
            iy,
            math.min(iw, fill_w),
            ih,
            self.fill_color,
            math.max(0, self.radius - 2)
        )
    end
    bb:paintBorder(x, y, bw, bh, Screen:scaleBySize(2), self.stroke_color, self.radius, 0)
    local tip_h = math.max(8, math.floor(bh * 0.35))
    local tx = x + bw + math.floor(self.tip_w / 4)
    local ty = y + math.floor((bh - tip_h) / 2)
    bb:paintRect(tx, ty, self.tip_w, tip_h, self.stroke_color)
    if self.face and self.label and self.label ~= "" then
        local sz = RenderText:sizeUtf8Text(0, iw, self.face, self.label, true, true)
        local tw = sz.x
        local cx = ix + math.max(0, math.floor((iw - tw) / 2))
        local baseline = iy + math.floor(ih / 2 - (sz.y_bottom - sz.y_top) / 2)
        RenderText:renderUtf8Text(bb, cx, baseline, self.face, self.label, true, true, self.text_color, iw)
    end
end

return BatteryGlyph
