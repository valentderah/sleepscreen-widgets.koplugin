local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")

local Settings = require("settings")

local GridEditor = require("grid.grid_editor")

local _ = require("l10n").gettext

local MenuLayout = {}

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
        text = _("Banner margin"),
        callback = function()
            edit_banner_number(_("Margin"), function()
                return Settings:effectiveBanner().margin
            end, function(n)
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.margin = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Banner padding"),
        callback = function()
            edit_banner_number(_("Padding"), function()
                return Settings:effectiveBanner().padding
            end, function(n)
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.padding = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Max height % (20–100)"),
        callback = function()
            edit_banner_number(_("Max height"), function()
                return Settings:effectiveBanner().max_height
            end, function(n)
                n = math.max(20, math.min(100, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.max_height = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Widget corner radius (px)"),
        callback = function()
            edit_banner_number(_("Widget corner radius"), function()
                return Settings:effectiveBanner().widget_radius or 12
            end, function(n)
                n = math.max(0, math.min(48, math.floor(n)))
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
                return Settings:effectiveBanner().widget_padding or 8
            end, function(n)
                n = math.max(0, math.min(32, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.widget_padding = n
                lua:saveSetting("banner", banner)
                Settings:flush()
            end)
        end,
    })

    table.insert(items, {
        text = _("Widget vertical gap (px)"),
        callback = function()
            edit_banner_number(_("Widget vertical gap"), function()
                return Settings:effectiveBanner().widget_gap or 6
            end, function(n)
                n = math.max(0, math.min(24, math.floor(n)))
                local lua = Settings:open()
                local banner = lua:readSetting("banner") or {}
                banner.widget_gap = n
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
            text = _("Grid zones (3×3)"),
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
