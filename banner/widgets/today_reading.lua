local Font = require("ui/font")
local Device = require("device")
local ProgressWidget = require("ui/widget/progresswidget")
local Screen = Device.screen
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local FrameStyle = require("banner.frame_style")
local reading_stats_day = require("data.reading_stats_day")

local _ = require("l10n").gettext

local M = {}

function M.register(Registry)
    Registry.register("today_reading", function(params, ctx)
        local max_w = ctx.cell_max_w or 100
        local pal = ctx.card_palette or FrameStyle.card_colors_light()

        local sec = select(1, reading_stats_day.total_seconds_today())
        local minutes = 0
        if type(sec) == "number" then
            minutes = math.floor(sec / 60)
        end

        local goal = tonumber(params.daily_goal_minutes) or 0
        local pct
        if goal > 0 then
            pct = math.max(0, math.min(1, minutes / goal))
        elseif minutes > 0 then
            pct = 1
        else
            pct = 0
        end

        local col = VerticalGroup:new{ align = "center" }
        local header = type(params.label) == "string" and params.label ~= "" and params.label
            or _("READING · TODAY")
        table.insert(col, TextBoxWidget:new{
            text = header,
            face = Font:getFace("cfont", 12),
            width = max_w,
            fgcolor = pal.text_secondary,
            bold = false,
            alignment = "center",
        })
        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(6) })

        table.insert(col, TextWidget:new{
            text = tostring(minutes),
            face = Font:getFace("cfont", 26),
            bold = true,
            fgcolor = pal.text_primary,
            padding = 0,
        })
        table.insert(col, TextWidget:new{
            text = _("MIN"),
            face = Font:getFace("cfont", 12),
            fgcolor = pal.text_secondary,
            padding = 0,
        })
        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(8) })
        table.insert(col, ProgressWidget:new{
            width = max_w,
            height = Screen:scaleBySize(8),
            percentage = pct,
            margin_v = 0,
            margin_h = 0,
            radius = Screen:scaleBySize(4),
            bordersize = 0,
            bgcolor = pal.progress_track,
            fillcolor = pal.progress_fill,
        })
        return col
    end)
end

return M
