--[[ Persistence for grid banner + banner chrome. ]]
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local util = require("util")

local Config = require("config")
local GridModel = require("grid.grid_model")
local Registry = require("banner.widgets.registry")

local SETTINGS_BASENAME = "sleepscreen_widgets.lua"

--- Dropped widget types: removed from grid on load/save (no migration to another type).
local REMOVED_WIDGET_TYPES = { sleep_stats = true }

local Settings = {}
Settings._lua = nil

local function strip_removed_widget_placements(list)
    if type(list) ~= "table" then
        return {}
    end
    local out = {}
    for _, p in ipairs(list) do
        if type(p) == "table" and type(p.type) == "string" and not REMOVED_WIDGET_TYPES[p.type] then
            table.insert(out, p)
        end
    end
    return out
end

local function settings_path(dir)
    return dir .. "/" .. SETTINGS_BASENAME
end

function Settings:getSettingsDir()
    return DataStorage:getSettingsDir()
end

function Settings:open()
    if self._lua then return self._lua end
    local path = settings_path(self:getSettingsDir())
    self._lua = LuaSettings:open(path)

    local function span_fn(t)
        return Registry.default_col_span(t)
    end

    local function seed_default_grid_if_absent(lua)
        if lua:readSetting("grid") ~= nil then
            return
        end
        Registry.ensure_registered()
        local placements = GridModel.normalizePlacements(Config.DEFAULT_GRID_PLACEMENTS, span_fn)
        lua:saveSetting("grid", GridModel.wrapSaved(placements))
        lua:flush()
    end

    local sv = self._lua:readSetting("schema_version") or 0
    if sv < Config.SCHEMA_VERSION then
        Registry.ensure_registered()
        local raw = self._lua:readSetting("grid")
        local placements
        if raw == nil then
            placements = GridModel.normalizePlacements(Config.DEFAULT_GRID_PLACEMENTS, span_fn)
        else
            placements = strip_removed_widget_placements(GridModel.parseSaved(raw, span_fn))
        end
        self._lua:saveSetting("grid", GridModel.wrapSaved(placements))
        self._lua:saveSetting("schema_version", Config.SCHEMA_VERSION)
        self._lua:flush()
    end

    seed_default_grid_if_absent(self._lua)

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
    return strip_removed_widget_placements(GridModel.parseSaved(raw, grid_default_span))
end

function Settings:saveGridPlacements(placements)
    Registry.ensure_registered()
    placements = strip_removed_widget_placements(placements)
    local norm = GridModel.normalizePlacements(placements, grid_default_span)
    self:open():saveSetting("grid", GridModel.wrapSaved(norm))
    self:flush()
end

return Settings
