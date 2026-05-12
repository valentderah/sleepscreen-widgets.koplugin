local TextViewer = require("ui/widget/textviewer")
local UIManager = require("ui/uimanager")

local Settings = require("settings")

local MenuLayout = require("menu.menu_layout")
local placeholder_help = require("placeholders")

local _ = require("l10n").gettext

local MenuSleep = {}

function MenuSleep.buildEnableToggleEntry()
    require("l10n").load()
    return {
        text = _("Awesome sleepscreen (sleep banner)"),
        help_text = _("When ON, replaces the sleep-screen banner with the 6×3 grid layout when KOReader uses Banner message mode."),
        checked_func = function()
            return Settings:isPluginEnabled()
        end,
        callback = function()
            Settings:setPluginEnabled(not Settings:isPluginEnabled())
        end,
    }
end

function MenuSleep.buildLayoutRootEntry(plugin_inst)
    require("l10n").load()
    return {
        text = _("Sleep screen layout"),
        help_text = _("Grid zones and banner appearance."),
        sub_item_table_func = function()
            return MenuLayout.buildLayoutRootSubmenu(plugin_inst)
        end,
    }
end

function MenuSleep.buildHelpEntry()
    require("l10n").load()
    return {
        text = _("Sleep screen placeholder codes"),
        callback = function()
            local body = placeholder_help(_)
            UIManager:show(TextViewer:new{
                title = _("Sleep screen placeholder codes"),
                text = body,
                justified = false,
                alignment = "left",
            })
        end,
    }
end

function MenuSleep.buildFallbackCombinedEntry(plugin_inst)
    require("l10n").load()
    return {
        text = _("Awesome sleepscreen"),
        separator = true,
        sub_item_table_func = function()
            return {
                MenuSleep.buildEnableToggleEntry(),
                MenuSleep.buildLayoutRootEntry(plugin_inst),
                MenuSleep.buildHelpEntry(),
            }
        end,
    }
end

return MenuSleep
