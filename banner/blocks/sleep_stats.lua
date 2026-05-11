local Font = require("ui/font")
local VerticalSpan = require("ui/widget/verticalspan")

local BannerText = require("banner.text")

local M = {}

function M.register(Registry)
    Registry.register("sleep_stats", function(params, ctx)
        local B_SETT = ctx.B_SETT
        local HL_SETT = ctx.HL_SETT
        local face = Font:getFace(B_SETT.stats_fontFace, B_SETT.stats_fontSize)
            or Font:getFace("cfont", 17)
        local text
        if params.mode == "template" and type(params.pattern) == "string" and params.pattern:match("%S") then
            text = BannerText.expand_string(ctx.ui_inst, params.pattern, ctx.last_file) or ""
        else
            text = ctx.orig_sleep_text or ""
        end
        if text == "" then
            return VerticalSpan:new{ width = 1 }
        end
        return BannerText.buildTextField(B_SETT, HL_SETT, text, face, ctx.cell_max_h, ctx.cell_max_w, false)
    end)
end

return M
