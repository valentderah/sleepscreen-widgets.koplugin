local Blitbuffer = require("ffi/blitbuffer")
local Geom = require("ui/geometry")
local Device = require("device")
local Screen = Device.screen
local InputDialog = require("ui/widget/inputdialog")
local OverlapGroup = require("ui/widget/overlapgroup")
local Widget = require("ui/widget/widget")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")

local Settings = require("settings")

local _ = require("gettext")

local M = {}
M._showing = false

local function dim_bb_color(level)
    local Bb = Blitbuffer
    -- Do not compare BB colors with nil via == / ~= — Color8 __eq crashes on nil operand.
    local map = {
        Bb.COLOR_GRAY_9,
        Bb.COLOR_GRAY_7,
        Bb.COLOR_GRAY_5,
        Bb.COLOR_GRAY_3,
    }
    if type(level) == "number" and level >= 1 and level <= 4 then
        local c = map[level]
        if c then
            return c
        end
    end
    return Bb.COLOR_GRAY_5
end

--- Крапинка поверх плоского серого (уровень затемнения как в dim_bb_color).
local function dim_dot_params(level)
    level = (type(level) == "number" and level >= 1 and level <= 4) and level or 3
    local presets = {
        { step = 5, dot_alpha = 0x52, blob = 2 },
        { step = 4, dot_alpha = 0x62, blob = 2 },
        { step = 4, dot_alpha = 0x72, blob = 2 },
        { step = 3, dot_alpha = 0x82, blob = 2 },
    }
    return presets[level]
end

local function paint_kindle_dot_dim(bb, abs_x, abs_y, w, h, level)
    bb:paintRect(abs_x, abs_y, w, h, dim_bb_color(level))

    if type(bb.setPixelAdd) ~= "function" then
        return
    end

    local p = dim_dot_params(level)
    local step = math.max(3, Screen:scaleBySize(p.step))
    local blob = math.max(1, math.min(3, p.blob))
    local da = p.dot_alpha

    for py = 0, h - 1, step do
        local row = math.floor(py / step)
        local x0 = (row % 2 == 1) and math.floor(step / 2) or 0
        for px = x0, w - 1, step do
            for by = 0, blob - 1 do
                for bx = 0, blob - 1 do
                    bb:setPixelAdd(abs_x + px + bx, abs_y + py + by, Blitbuffer.COLOR_BLACK, da)
                end
            end
        end
    end
end

local DimMask = Widget:extend{
    name = "awesome_sleepscreen_lock_dim",
}

function DimMask:init()
    self.dim_level = self.dim_level or 3
    self.dimen = Geom:new{
        x = 0,
        y = 0,
        w = Screen:getWidth(),
        h = Screen:getHeight(),
    }
end

function DimMask:paintTo(bb, x, y)
    paint_kindle_dot_dim(bb, x, y, self.dimen.w, self.dimen.h, self.dim_level)
end

local function close_overlay(root)
    UIManager:close(root, "full")
    M._showing = false
    UIManager:nextTick(function()
        UIManager:setDirty(nil, "full")
    end)
end

function M.showUnlockPrompt(opts)
    opts = opts or {}
    if M._showing then return end
    local skip_pin_check = opts.test_preview == true
    if not Settings:isLockEnabled() and not skip_pin_check then return end
    local pin_expected = Settings:getLockPin()
    if pin_expected == "" and not skip_pin_check then return end

    M._showing = true

    local ctx = {}

    ctx.dlg = InputDialog:new{
        title = _("Unlock"),
        input = "",
        text_type = "password",
        input_hint = _("PIN"),
        deny_keyboard_hiding = true,
        edited_callback = function()
            if ctx.root then
                UIManager:setDirty(ctx.root, "ui")
            end
        end,
        buttons = {{
            {
                text = _("Unlock"),
                is_enter_default = true,
                callback = function()
                    local d = ctx.dlg
                    if not d then return end
                    local entered = d:getInputText()
                    if skip_pin_check or entered == pin_expected then
                        close_overlay(ctx.root)
                    else
                        UIManager:show(InfoMessage:new{
                            text = _("Wrong PIN."),
                            timeout = 2,
                        })
                    end
                end,
            },
        }},
    }

    local dlg = ctx.dlg
    local og_dimen = Geom:new{
        x = 0,
        y = 0,
        w = Screen:getWidth(),
        h = Screen:getHeight(),
    }

    local mask = DimMask:new{
        dim_level = Settings:getLockDimLevel(),
    }

    -- InputDialog already centers itself on screen.  Wrapping it in an extra
    -- CenterContainer shifts it down by keyboard_h/2, placing buttons behind
    -- the keyboard gesture zone.  Put dlg directly into OverlapGroup instead.
    ctx.root = OverlapGroup:new{
        allow_mirroring = false,
        dimen = og_dimen,
        modal = true,
        covers_fullscreen = true,
    }
    table.insert(ctx.root, mask)
    table.insert(ctx.root, dlg)

    UIManager:show(ctx.root)
    dlg:onShowKeyboard()
    UIManager:nextTick(function()
        UIManager:setDirty(ctx.root, "ui")
    end)
end

function M.showTestPrompt()
    M.showUnlockPrompt({ test_preview = true })
end

function M.onResume(_plugin_inst)
    if not Settings:isLockEnabled() or Settings:getLockPin() == "" then
        return
    end
    UIManager:scheduleIn(0.08, function()
        M.showUnlockPrompt({})
    end)
end

return M
