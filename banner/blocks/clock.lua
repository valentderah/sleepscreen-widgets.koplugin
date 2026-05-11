local Font = require("ui/font")

local BannerText = require("banner.text")

local M = {}

function M.register(Registry)
    Registry.register("clock", function(params, ctx)
        local B_SETT = ctx.B_SETT
        local HL_SETT = ctx.HL_SETT
        local fmt = (type(params.format) == "string" and params.format ~= "") and params.format or "%H:%M"
        local text = os.date(fmt)
        local face = Font:getFace(params.font_face or "cfont", params.font_size or 22)
        return BannerText.buildTextField(B_SETT, HL_SETT, text, face, ctx.cell_max_h, ctx.cell_max_w, true)
    end)
end

return M
