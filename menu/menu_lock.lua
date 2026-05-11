local InfoMessage = require("ui/widget/infomessage")
local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")

local Settings = require("settings")

local LockOverlay = require("menu.lock_overlay")

local _ = require("l10n").gettext

local MenuLock = {}

function MenuLock.buildLockSubmenu()
    require("l10n").load()
    return {
        {
            text = _("Require PIN after wake"),
            checked_func = function()
                return Settings:isLockEnabled()
            end,
            callback = function()
                Settings:setLockEnabled(not Settings:isLockEnabled())
            end,
        },
        {
            text = _("Set or change PIN…"),
            callback = function()
                if not Settings:isLockWarnSeen() then
                    UIManager:show(InfoMessage:new{
                        text = _([[Basic privacy only — not strong security. PIN is stored in plain form on the device.]]),
                        timeout = 5,
                    })
                    Settings:setLockWarnSeen()
                end
                local pin1 = ""
                local dlg1
                dlg1 = InputDialog:new{
                    title = _("New PIN"),
                    input = "",
                    input_hint = _("PIN"),
                    text_type = "password",
                    buttons = {{
                        {
                            text = _("Cancel"),
                            callback = function()
                                UIManager:close(dlg1)
                            end,
                        },
                        {
                            text = _("Next"),
                            is_enter_default = true,
                            callback = function()
                                pin1 = dlg1:getInputText()
                                UIManager:close(dlg1)
                                local dlg2
                                dlg2 = InputDialog:new{
                                    title = _("Confirm PIN"),
                                    input = "",
                                    text_type = "password",
                                    buttons = {{
                                        {
                                            text = _("Cancel"),
                                            callback = function()
                                                UIManager:close(dlg2)
                                            end,
                                        },
                                        {
                                            text = _("Save"),
                                            is_enter_default = true,
                                            callback = function()
                                                local pin2 = dlg2:getInputText()
                                                if pin1 ~= pin2 then
                                                    UIManager:show(InfoMessage:new{
                                                        text = _("PINs do not match."),
                                                        timeout = 3,
                                                    })
                                                else
                                                    Settings:setLockPin(pin1)
                                                    UIManager:show(InfoMessage:new{
                                                        text = _("PIN saved."),
                                                        timeout = 2,
                                                    })
                                                end
                                                UIManager:close(dlg2)
                                            end,
                                        },
                                    }},
                                }
                                UIManager:show(dlg2)
                                dlg2:onShowKeyboard()
                            end,
                        },
                    }},
                }
                UIManager:show(dlg1)
                dlg1:onShowKeyboard()
            end,
        },
        {
            text = _("Dim level (1 light → 4 dark)"),
            sub_item_table_func = function()
                local items = {}
                for lv = 1, 4 do
                    table.insert(items, {
                        text = tostring(lv),
                        radio = true,
                        checked_func = function()
                            return Settings:getLockDimLevel() == lv
                        end,
                        callback = function()
                            Settings:setLockDimLevel(lv)
                        end,
                    })
                end
                return items
            end,
        },
        {
            text = _("Preview lock screen"),
            callback = function()
                LockOverlay.showTestPrompt()
            end,
        },
    }
end

return MenuLock
