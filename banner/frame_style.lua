local Blitbuffer = require("ffi/blitbuffer")
local Device = require("device")
local Screen = Device.screen

local M = {}

function M.scale(n)
    return Screen:scaleBySize(n)
end

function M.card_border_width(_B_SETT)
    return M.scale(4)
end

function M.card_colors_light()
    return {
        fill = Blitbuffer.COLOR_WHITE,
        border = Blitbuffer.COLOR_BLACK,
        text_primary = Blitbuffer.COLOR_BLACK,
        text_secondary = Blitbuffer.COLOR_GRAY_3, -- tune on e-ink toward #666
        progress_track = Blitbuffer.COLOR_GRAY_9, -- tune toward #E0E0E0
        progress_fill = Blitbuffer.COLOR_BLACK,
    }
end

function M.card_colors_dark_tile()
    local light = M.card_colors_light()
    return {
        fill = Blitbuffer.COLOR_BLACK,
        border = light.border,
        text_primary = Blitbuffer.COLOR_WHITE,
        text_secondary = Blitbuffer.COLOR_GRAY_9,
        progress_track = light.progress_track,
        progress_fill = light.progress_fill,
    }
end

return M
