--[[ Fixed square content area; child is painted centered (square card like analog clock). ]]
local Geom = require("ui/geometry")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

local SquareHolder = WidgetContainer:extend{
    name = "awesome_sleepscreen_square_holder",
    side = 100,
}

function SquareHolder:init()
    -- WidgetContainer has no init() on this KOReader version; do not call parent.
    local s = tonumber(self.side) or 100
    self.side = math.max(1, math.floor(s))
    self.dimen = Geom:new{ w = self.side, h = self.side }
end

function SquareHolder:getSize()
    local s = tonumber(self.side) or 0
    if s <= 0 then
        return Geom:new{ x = 0, y = 0, w = 0, h = 0 }
    end
    return Geom:new{ x = 0, y = 0, w = s, h = s }
end

function SquareHolder:paintTo(bb, x, y)
    local ch = self[1]
    if not ch or not ch.getSize or not ch.paintTo then
        return
    end
    local cs = ch:getSize()
    if not cs or (cs.w or 0) <= 0 or (cs.h or 0) <= 0 then
        return
    end
    local s = tonumber(self.side) or 0
    if s <= 0 then
        return
    end
    local cx = x + math.floor((s - cs.w) / 2)
    local cy = y + math.floor((s - cs.h) / 2)
    ch:paintTo(bb, cx, cy)
end

return SquareHolder
