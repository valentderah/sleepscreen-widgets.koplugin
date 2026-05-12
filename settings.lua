--[[ Persistence for grid banner + banner chrome. ]]
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local util = require("util")

local Config = require("config")
local GridModel = require("grid.grid_model")
local Registry = require("banner.widgets.registry")

local NEW_SETTINGS_BASENAME = "awesome_sleepscreen.lua"
local LEGACY_SETTINGS_BASENAMES = {
    "awesome_lockscreen.lua",
    "custom_sleepscreen.lua",
}

local Settings = {}
Settings._lua = nil

local function resolve_settings_path(dir)
    local new_path = dir .. "/" .. NEW_SETTINGS_BASENAME
    local ok_lfs, lfs = pcall(require, "libs/libkoreader-lfs")
    if not (ok_lfs and lfs and lfs.attributes) then
        return new_path
    end
    if lfs.attributes(new_path, "mode") == "file" then
        return new_path
    end
    for _, base in ipairs(LEGACY_SETTINGS_BASENAMES) do
        local leg = dir .. "/" .. base
        if lfs.attributes(leg, "mode") == "file" then
            local renamed = false
            if lfs.rename then
                renamed = select(1, pcall(lfs.rename, leg, new_path))
            end
            if not renamed then
                pcall(os.rename, leg, new_path)
            end
            if lfs.attributes(new_path, "mode") == "file" then
                return new_path
            end
            return leg
        end
    end
    return new_path
end

function Settings:getSettingsDir()
    return DataStorage:getSettingsDir()
end

function Settings:open()
    if self._lua then return self._lua end
    local path = resolve_settings_path(self:getSettingsDir())
    self._lua = LuaSettings:open(path)

    local sv = self._lua:readSetting("schema_version") or 0
    if sv < Config.SCHEMA_VERSION then
        if self._lua:readSetting("grid") == nil then
            self._lua:saveSetting("grid", GridModel.emptySaved())
        end
        if sv < (Config.SCHEMA_GRID_PLACEMENTS_AT or 6) then
            Registry.ensure_registered()
            local raw = self._lua:readSetting("grid")
            local placements = GridModel.parseSaved(raw, function(t)
                return Registry.default_col_span(t)
            end)
            self._lua:saveSetting("grid", GridModel.wrapSaved(placements))
        end
        if sv < Config.SCHEMA_LOCK_KEYS_REMOVED_AT then
            for _, k in ipairs({
                "lock_enabled",
                "lock_pin",
                "lock_dim_level",
                "lock_warn_seen",
            }) do
                if self._lua.delSetting then
                    pcall(function()
                        self._lua:delSetting(k)
                    end)
                end
            end
        end
        self._lua:saveSetting("schema_version", Config.SCHEMA_VERSION)
        self._lua:flush()
    end

    return self._lua
end

function Settings:flush()
    if self._lua then self._lua:flush() end
end

function Settings:isPluginEnabled()
    return self:open():readSetting("plugin_enabled") ~= false
end

function Settings:setPluginEnabled(enabled)
    self:open():saveSetting("plugin_enabled", enabled and true or false)
    self:flush()
end

function Settings:effectiveBanner()
    local b = {}
    util.tableMerge(b, Config.DEFAULT_BANNER)
    local saved = self:open():readSetting("banner") or {}
    util.tableMerge(b, saved)
    return b
end

local function grid_default_span(type_id)
    Registry.ensure_registered()
    return Registry.default_col_span(type_id)
end

function Settings:getGridPlacements()
    local raw = self:open():readSetting("grid")
    return GridModel.parseSaved(raw, grid_default_span)
end

function Settings:saveGridPlacements(placements)
    Registry.ensure_registered()
    local norm = GridModel.normalizePlacements(placements, grid_default_span)
    self:open():saveSetting("grid", GridModel.wrapSaved(norm))
    self:flush()
end

---@deprecated use getGridPlacements
function Settings:getGridZones()
    return self:getGridPlacements()
end

---@deprecated use saveGridPlacements
function Settings:saveGridZones(zones)
    self:saveGridPlacements(zones)
end

return Settings
