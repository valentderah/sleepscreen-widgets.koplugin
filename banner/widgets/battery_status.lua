local Device = require("device")
local Font = require("ui/font")

local BatteryGlyph = require("banner.widgets.battery_glyph")
local FrameStyle = require("banner.frame_style")

local M = {}

local function fit_dims(ctx)
    local mw = tonumber(ctx.cell_max_w) or 160
    local mh = tonumber(ctx.cell_max_h) or 80
    local m = math.min(mw, mh)
    local body_h = math.max(32, math.floor(m * 0.55))
    local body_w = math.max(48, math.floor(mw * 0.85))
    if body_w + 8 > mw then
        body_w = mw - 8
    end
    return body_w, body_h
end

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
        local label = string.format("%d%%", math.floor(tonumber(lvl) or 0))
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        local body_w, body_h = fit_dims(ctx)
        local base_fs = tonumber(params and params.font_size) or 16
        local face = Font:getFace("cfont", base_fs)
        return BatteryGlyph:new{
            capacity = tonumber(lvl) or 0,
            label = label,
            face = face,
            fill_color = pal.fill,
            stroke_color = pal.text_primary,
            level_color = pal.text_secondary,
            text_color = pal.text_primary,
            body_w = body_w,
            body_h = body_h,
            tip_w = math.max(4, math.floor(body_h * 0.12)),
            radius = math.max(4, math.floor(body_h * 0.15)),
            inner_pad = math.max(3, math.floor(body_h * 0.08)),
        }
    end)
end

return M
