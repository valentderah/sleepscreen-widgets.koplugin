local Font = require("ui/font")
local VerticalSpan = require("ui/widget/verticalspan")

local BannerText = require("banner.text")
local FrameStyle = require("banner.frame_style")
local WidgetSpan = require("banner.widget_span")

local M = {}

function M.register(Registry)
    Registry.register("template", function(params, ctx)
        local pattern = params.pattern
        if type(pattern) ~= "string" or pattern == "" then
            return VerticalSpan:new{ width = 1 }
        end
        local B_SETT = ctx.B_SETT
        local HL_SETT = ctx.HL_SETT
        local face
        if params.font_face and params.font_size then
            face = Font:getFace(params.font_face, WidgetSpan.scaled_font_size(params.font_size, ctx))
        elseif params.role == "stats" then
            face = Font:getFace(
                B_SETT.stats_fontFace,
                WidgetSpan.scaled_font_size(B_SETT.stats_fontSize or 17, ctx)
            ) or Font:getFace("cfont", WidgetSpan.scaled_font_size(17, ctx))
        else
            face = Font:getFace(
                B_SETT.title_fontFace,
                WidgetSpan.scaled_font_size(B_SETT.title_fontSize or 30, ctx)
            ) or Font:getFace("cfont", WidgetSpan.scaled_font_size(30, ctx))
        end
        face = face or Font:getFace("cfont", WidgetSpan.scaled_font_size(30, ctx))
        local text = BannerText.expand_string(ctx.ui_inst, pattern, ctx.last_file) or ""
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
