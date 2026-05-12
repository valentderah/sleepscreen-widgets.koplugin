local Device = require("device")
local Font = require("ui/font")
local Screen = Device.screen
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local FrameStyle = require("banner.frame_style")

local M = {}

function M.register(Registry)
    Registry.register("calendar_tile", function(params, ctx)
        local max_w = ctx.cell_max_w or 100
        local pal = ctx.card_palette or FrameStyle.card_colors_dark_tile()
        local month_fmt = (type(params.month_format) == "string" and params.month_format ~= "")
            and params.month_format or "%b"
        local day_num = tonumber(os.date("%d")) or 1
        local month_str = string.upper(os.date(month_fmt))
        local day_size = params.day_size or 32
        local month_size = params.month_size or 14

        local col = VerticalGroup:new{ align = "center" }
        -- Decorative "rings" — minimal placeholder (two dots)
        table.insert(col, TextWidget:new{
            text = "·  ·",
            face = Font:getFace("cfont", 10),
            fgcolor = pal.text_secondary,
            padding = 0,
            bgcolor = pal.fill,
        })
        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(2) })
        table.insert(col, TextBoxWidget:new{
            text = month_str,
            face = Font:getFace("cfont", month_size),
            width = max_w,
            fgcolor = pal.text_secondary,
            bgcolor = pal.fill,
            alignment = "center",
            bold = true,
        })
        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(4) })
        table.insert(col, TextWidget:new{
            text = tostring(day_num),
            face = Font:getFace("cfont", day_size),
            bold = true,
            fgcolor = pal.text_primary,
            padding = 0,
            bgcolor = pal.fill,
        })
        return col
    end)
end

return M
