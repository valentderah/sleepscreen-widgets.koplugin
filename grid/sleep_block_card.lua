local Blitbuffer = require("ffi/blitbuffer")
local Geom = require("ui/geometry")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

local CardGeometry = require("grid.card_geometry")

local SleepBlockCard = WidgetContainer:extend{
    name = "awesome_sleepscreen_sleep_block_card",
    B_SETT = nil,
    radius = 0,
    pad_h = 0,
    pad_v = 0,
}

function SleepBlockCard:init()
    local b = self.B_SETT or {}
    if b.background == 0 then
        self.fill_c = Blitbuffer.COLOR_GRAY_E
        self.border_c = Blitbuffer.COLOR_GRAY_5
    else
        self.fill_c = Blitbuffer.COLOR_GRAY_3
        self.border_c = Blitbuffer.COLOR_GRAY_7
    end
end

function SleepBlockCard:getSize()
    local child = self[1]
    if not child or not child.getSize then
        return Geom:new{ x = 0, y = 0, w = 0, h = 0 }
    end
    local s = child:getSize()
    if not s or (s.w or 0) <= 0 or (s.h or 0) <= 0 then
        return Geom:new{ x = 0, y = 0, w = 0, h = 0 }
    end
    local ow, oh = CardGeometry.outer_size(s.w, s.h, self.pad_h, self.pad_v)
    return Geom:new{ x = 0, y = 0, w = ow, h = oh }
end

function SleepBlockCard:paintTo(bb, x, y)
    local child = self[1]
    if not child or not child.getSize or not child.paintTo then
        return
    end
    local s = child:getSize()
    if not s or (s.w or 0) <= 0 or (s.h or 0) <= 0 then
        return
    end
    local ow, oh = CardGeometry.outer_size(s.w, s.h, self.pad_h, self.pad_v)
    if ow <= 0 or oh <= 0 then
        return
    end
    local r = self.radius or 0
    bb:paintRoundedRect(x, y, ow, oh, self.fill_c, r)
    bb:paintBorder(x, y, ow, oh, 1, self.border_c, r, 0)
    child:paintTo(bb, x + self.pad_h, y + self.pad_v)
end

return SleepBlockCard
