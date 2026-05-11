local ReaderMenu = require("apps/reader/modules/readermenu")
local _ = require("gettext")

local hooked = false
local plugin_inst

local function looks_like_stock_screensaver_submenu(sub_item_table)
    if type(sub_item_table) ~= "table" then return false end
    local a, b = sub_item_table[1], sub_item_table[2]
    if not (a and b and type(a) == "table" and type(b) == "table") then return false end
    return a.text == _("Wallpaper") and b.text == _("Sleep screen message")
end

local function strip_old_custom_entries(sub_item_table)
    if not sub_item_table then return end
    for i = #sub_item_table, 1, -1 do
        local item = sub_item_table[i]
        if item._awesome_sleepscreen or item._awesome_lockscreen
            or item._custom_sleepscreen or item._custom_sleepscreen_banner then
            table.remove(sub_item_table, i)
        end
    end
end

local function append_custom_entries(sub_item_table)
    if not sub_item_table then return end
    strip_old_custom_entries(sub_item_table)
    local MenuSleep = require("menu.menu_sleep")
    local entries = {
        MenuSleep.buildEnableToggleEntry(),
        MenuSleep.buildLayoutRootEntry(plugin_inst),
        MenuSleep.buildLockRootEntry(plugin_inst),
        MenuSleep.buildHelpEntry(),
    }
    for _, entry in ipairs(entries) do
        entry._awesome_sleepscreen = true
        table.insert(sub_item_table, entry)
    end
end

local function inject_via_menu_items(menu_items)
    local ss = menu_items and menu_items.screensaver
    append_custom_entries(ss and ss.sub_item_table)
end

local function try_inject_into_screensaver_node(node)
    if type(node) ~= "table" then return false end
    local sub = node.sub_item_table
    if not sub then return false end
    if node.id == "screensaver" or looks_like_stock_screensaver_submenu(sub) then
        append_custom_entries(sub)
        return true
    end
    return false
end

local function inject_via_tab_item_table(tab_item_table)
    if not tab_item_table then return false end

    local function visit_level(nodes)
        if type(nodes) ~= "table" then return false end
        local n = #nodes
        for i = 1, n do
            local node = nodes[i]
            if try_inject_into_screensaver_node(node) then
                return true
            end
            if node and node.sub_item_table then
                if visit_level(node.sub_item_table) then
                    return true
                end
            end
            if node and node.sub_item_table_func then
                local lazy = node.sub_item_table_func()
                if lazy and visit_level(lazy) then
                    return true
                end
            end
        end
        return false
    end

    for t = 1, #tab_item_table do
        local tab_root = tab_item_table[t]
        if tab_root and visit_level(tab_root) then
            return true
        end
    end
    return false
end

local function inject_fallback_combined(menu_items)
    local MenuSleep = require("menu.menu_sleep")
    menu_items.awesome_sleepscreen_fallback = MenuSleep.buildFallbackCombinedEntry(plugin_inst)
    menu_items.awesome_sleepscreen_fallback.id = "awesome_sleepscreen_fallback"
end

local function patch_menu_class(MenuClass)
    if MenuClass._sleepscreen_banner_menu_patched then return end
    local orig = MenuClass.setUpdateItemTable
    MenuClass.setUpdateItemTable = function(self, ...)
        orig(self, ...)
        inject_via_menu_items(self.menu_items)
        if not inject_via_tab_item_table(self.tab_item_table) then
            inject_fallback_combined(self.menu_items)
        end
    end
    MenuClass._sleepscreen_banner_menu_patched = true
end

local M = {}

function M.install(inst)
    if hooked then return end
    plugin_inst = inst
    patch_menu_class(ReaderMenu)
    local ok, FileManagerMenu = pcall(require, "apps/filemanager/filemanagermenu")
    if ok and FileManagerMenu then
        patch_menu_class(FileManagerMenu)
    end
    hooked = true
end

return M
