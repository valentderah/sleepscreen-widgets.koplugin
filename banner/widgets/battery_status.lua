local Device = require("device")
local Font = require("ui/font")
local TextBoxWidget = require("ui/widget/textboxwidget")

local FrameStyle = require("banner.frame_style")

local M = {}

function M.register(Registry)
    Registry.register("battery_status", function(params, ctx)
        if not Device:hasBattery() then
            return nil
        end
        local power = Device:getPowerDevice()
        if not power then
            return nil
        end
        local lvl = power:getCapacity() or 0
        local is_charging = power:isCharging() or false
        local charged = type(power.isCharged) == "function" and power:isCharged() or false
        local sym = ""
        if power.getBatterySymbol then
            sym = power:getBatterySymbol(charged, is_charging, lvl) or ""
        end
        local text = string.format("%s%d%%", sym, math.floor(tonumber(lvl) or 0))
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        local max_w = ctx.cell_max_w or 200
        return TextBoxWidget:new{
            text = text,
            face = Font:getFace("cfont", (params and tonumber(params.font_size)) or 16),
            width = max_w,
            fgcolor = pal.text_primary,
            alignment = "center",
        }
    end)
end

return M
