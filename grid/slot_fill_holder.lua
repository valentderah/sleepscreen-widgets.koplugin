--[[ Fixed inner size matching the padded slot; child is painted centered (full card = slot minus widget_padding). ]]
local Geom = require("ui/geometry")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

local SlotFillHolder = WidgetContainer:extend{
    name = "sleepscreen_widgets_slot_fill_holder",
    inner_w = 1,
    inner_h = 1,
}

function SlotFillHolder:init()
    self.inner_w = math.max(1, math.floor(tonumber(self.inner_w) or 1))
    self.inner_h = math.max(1, math.floor(tonumber(self.inner_h) or 1))
end

function SlotFillHolder:getSize()
    return Geom:new{ x = 0, y = 0, w = self.inner_w, h = self.inner_h }
end

function SlotFillHolder:paintTo(bb, x, y)
    local inner = self[1]
    if not inner or not inner.getSize or not inner.paintTo then
        return
    end
    local isz = inner:getSize()
    local iw = isz.w or 0
    local ih = isz.h or 0
    local cx = x + math.max(0, math.floor((self.inner_w - iw) / 2))
    local cy = y + math.max(0, math.floor((self.inner_h - ih) / 2))
    inner:paintTo(bb, cx, cy)
end

return SlotFillHolder
