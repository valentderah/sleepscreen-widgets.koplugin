local Device = require("device")
local Font = require("ui/font")
local Screen = Device.screen
local TextBoxWidget = require("ui/widget/textboxwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local FrameStyle = require("banner.frame_style")
local WidgetSpan = require("banner.widget_span")

local M = {}

function M.register(Registry)
    Registry.register("header_datetime", function(params, ctx)
        local max_w = ctx.cell_max_w or 100
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        local date_fmt = (type(params.date_format) == "string" and params.date_format ~= "")
            and params.date_format or "%A, %B %d"
        local time_fmt = (type(params.time_format) == "string" and params.time_format ~= "")
            and params.time_format or "%H:%M"
        local date_text = string.upper(os.date(date_fmt))
        local time_text = os.date(time_fmt)
        local date_size = tonumber(params.date_size) or 14
        local time_size = tonumber(params.time_size) or 28
        if WidgetSpan.col_span(ctx) >= 2 then
            date_size = math.floor(date_size * 1.08 + 0.5)
            time_size = math.floor(time_size * 1.08 + 0.5)
        end

        local col = VerticalGroup:new{ align = "center" }
        table.insert(col, TextBoxWidget:new{
            text = date_text,
            face = Font:getFace("cfont", date_size),
            width = max_w,
            fgcolor = pal.text_secondary,
            alignment = "center",
            bold = false,
        })
        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(4) })
        table.insert(col, TextBoxWidget:new{
            text = time_text,
            face = Font:getFace("cfont", time_size),
            width = max_w,
            fgcolor = pal.text_primary,
            alignment = "center",
            bold = true,
        })
        return col
    end, { default_col_span = 3 })
end

return M
