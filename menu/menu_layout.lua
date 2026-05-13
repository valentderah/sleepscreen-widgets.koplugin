local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")

local Config = require("config")
local Settings = require("settings")

local GridEditor = require("grid.grid_editor")

local _ = require("l10n").gettext

local MenuLayout = {}

local DEF = Config.DEFAULT_BANNER
local UI = Config.UI_LIMITS

local function grid_inset_max()
    return assert(tonumber(Config.GRID_EDGE_INSET_MAX), "config GRID_EDGE_INSET_MAX must be set")
end

local function edit_banner_number(title, read_fn, write_fn)
    local dlg
    dlg = InputDialog:new{
        title = title,
        input = tostring(read_fn()),
        buttons = {{
            {
                text = _("Cancel"),
                callback = function()
                    UIManager:close(dlg)
                end,
            },
            {
                text = _("Save"),
                is_enter_default = true,
                callback = function()
                    local n = tonumber(dlg:getInputText())
                    if n then
                        write_fn(n)
                    end
                    UIManager:close(dlg)
                end,
            },
        }},
    }
    UIManager:show(dlg)
    dlg:onShowKeyboard()
end

function MenuLayout.buildAppearanceSubmenu()
    require("l10n").load()
    local items = {}

    table.insert(items, {
        text = _("Widget corner radius (px)"),
        callback = function()
            edit_banner_number(_("Widget corner radius"), function()
                return Settings:effectiveBanner().widget_radius or DEF.widget_radius
            end, function(n)
                n = math.max(0, math.min(UI.widget_radius_px.max, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.widget_radius = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Widget padding (px)"),
        callback = function()
            edit_banner_number(_("Widget padding"), function()
                return Settings:effectiveBanner().widget_padding or DEF.widget_padding
            end, function(n)
                n = math.max(0, math.min(UI.widget_padding_px.max, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.widget_padding = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Grid horizontal inset from screen (px)"),
        help_text = _("Left/right margin between the screen border and the 6×3 grid; scaled for DPI. When unset, the combined \"legacy\" inset value is used for this axis."),
        callback = function()
            edit_banner_number(_("Grid horizontal inset (px)"), function()
                local b = Settings:effectiveBanner()
                local x = tonumber(b.grid_edge_margin_x)
                if x == nil then
                    x = tonumber(b.grid_edge_margin)
                end
                if x == nil then
                    x = DEF.grid_edge_margin_x
                end
                return math.max(0, math.min(grid_inset_max(), math.floor(x)))
            end, function(n)
                n = math.max(0, math.min(grid_inset_max(), math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.grid_edge_margin_x = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Grid vertical inset from screen (px)"),
        help_text = _("Top/bottom margin between the screen border and the 6×3 grid; scaled for DPI. When unset, the combined \"legacy\" inset value is used for this axis."),
        callback = function()
            edit_banner_number(_("Grid vertical inset (px)"), function()
                local b = Settings:effectiveBanner()
                local y = tonumber(b.grid_edge_margin_y)
                if y == nil then
                    y = tonumber(b.grid_edge_margin)
                end
                if y == nil then
                    y = DEF.grid_edge_margin_y
                end
                return math.max(0, math.min(grid_inset_max(), math.floor(y)))
            end, function(n)
                n = math.max(0, math.min(grid_inset_max(), math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.grid_edge_margin_y = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Default grid / widget gap (px)"),
        callback = function()
            edit_banner_number(_("Default gap"), function()
                return Settings:effectiveBanner().widget_gap or DEF.widget_gap
            end, function(n)
                n = math.max(0, math.min(UI.widget_gap_px.max, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.widget_gap = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Grid column gap (px, 0 = default gap)"),
        callback = function()
            edit_banner_number(_("Column gap"), function()
                local lua = Settings:open()
                local b = lua:readSetting("banner") or {}
                if b.grid_gutter_x ~= nil then return b.grid_gutter_x end
                return Settings:effectiveBanner().widget_gap or DEF.widget_gap
            end, function(n)
                n = math.max(0, math.min(UI.widget_gap_px.max, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.grid_gutter_x = n == 0 and nil or n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Grid row gap (px, 0 = default gap)"),
        callback = function()
            edit_banner_number(_("Row gap"), function()
                local lua = Settings:open()
                local b = lua:readSetting("banner") or {}
                if b.grid_gutter_y ~= nil then return b.grid_gutter_y end
                return Settings:effectiveBanner().widget_gap or DEF.widget_gap
            end, function(n)
                n = math.max(0, math.min(UI.widget_gap_px.max, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.grid_gutter_y = n == 0 and nil or n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    return items
end

function MenuLayout.buildLayoutRootSubmenu(_plugin_inst)
    require("l10n").load()
    return {
        {
            text = _("Sleep banner grid (6×3)"),
            sub_item_table_func = function()
                return GridEditor.gridZonesMenu()
            end,
        },
        {
            text = _("Banner appearance"),
            sub_item_table_func = function()
                return MenuLayout.buildAppearanceSubmenu()
            end,
        },
    }
end

return MenuLayout
