local Geom = require("ui/geometry")
local WidgetContainer = require("ui/widget/container/widgetcontainer")

local FrameStyle = require("banner.frame_style")
local CardGeometry = require("grid.card_geometry")

local SleepWidgetCard = WidgetContainer:extend{
    name = "sleepscreen_widgets_sleep_widget_card",
    B_SETT = nil,
    radius = 0,
    pad_h = 0,
    pad_v = 0,
}

function SleepWidgetCard:init()
    -- Optional `palette` from SleepWidgetCard:new{ palette = dark_tile } (e.g. calendar).
    self.palette = self.palette or FrameStyle.card_colors_light()
    self.fill_c = self.palette.fill
    self.border_c = self.palette.border
    self.border_w = FrameStyle.card_border_width(self.B_SETT)
end

function SleepWidgetCard:getSize()
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

function SleepWidgetCard:paintTo(bb, x, y)
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
    bb:paintBorder(x, y, ow, oh, self.border_w or FrameStyle.scale(4), self.border_c, r, 0)
    child:paintTo(bb, x + self.pad_h, y + self.pad_v)
end

return SleepWidgetCard
