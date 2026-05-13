local Font = require("ui/font")

local BannerText = require("banner.text")
local FrameStyle = require("banner.frame_style")
local WidgetSpan = require("banner.widget_span")

local M = {}

function M.register(Registry)
    Registry.register("clock", function(params, ctx)
        local B_SETT = ctx.B_SETT
        local HL_SETT = ctx.HL_SETT
        local fmt = (type(params.format) == "string" and params.format ~= "") and params.format or "%H:%M"
        local text = os.date(fmt)
        local sz = WidgetSpan.scaled_font_size(params.font_size or 22, ctx)
        local face = Font:getFace(params.font_face or "cfont", sz)
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        return BannerText.buildTextField(
            B_SETT,
            HL_SETT,
            text,
            face,
            ctx.cell_max_h,
            ctx.cell_max_w,
            true,
            false,
            pal.text_primary,
            pal.fill
        )
    end)
end

return M
