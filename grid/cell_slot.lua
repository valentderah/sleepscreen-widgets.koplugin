local Geom = require("ui/geometry")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

--[[ Forces a fixed layout size for HorizontalGroup: inner FrameContainer/SleepWidgetCard
    reports content-driven width (e.g. narrow square for span 1), but the row must reserve
    exactly slot_w × slot_h so multi-column spans align with N×slot + (N-1)×gutter. ]]
local CellSlot = WidgetContainer:extend{
    slot_w = 1,
    slot_h = 1,
}

function CellSlot:getSize()
    return Geom:new{
        x = 0,
        y = 0,
        w = math.max(1, math.floor(tonumber(self.slot_w) or 1)),
        h = math.max(1, math.floor(tonumber(self.slot_h) or 1)),
    }
end

function CellSlot:paintTo(bb, x, y)
    local child = self[1]
    if not child or not child.getSize or not child.paintTo then
        return
    end
    local s = child:getSize()
    local sw = s.w or 0
    local sh = s.h or 0
    local slot_w = math.max(1, math.floor(tonumber(self.slot_w) or 1))
    local slot_h = math.max(1, math.floor(tonumber(self.slot_h) or 1))
    local cx = x + math.max(0, math.floor((slot_w - sw) / 2))
    local cy = y + math.max(0, math.floor((slot_h - sh) / 2))
    child:paintTo(bb, cx, cy)
end

return CellSlot
