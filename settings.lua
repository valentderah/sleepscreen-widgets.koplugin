--[[ Persistence for grid banner + banner chrome + wake lock. ]]
local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local util = require("util")

local Config = require("config")
local GridModel = require("grid.grid_model")

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
            self._lua:saveSetting("grid", GridModel.emptyZones())
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

function Settings:getGridZones()
    local raw = self:open():readSetting("grid")
    return GridModel.normalizeZones(raw)
end

function Settings:saveGridZones(zones)
    self:open():saveSetting("grid", GridModel.normalizeZones(zones))
    self:flush()
end

function Settings:isLockEnabled()
    return self:open():readSetting("lock_enabled") == true
end

function Settings:setLockEnabled(v)
    self:open():saveSetting("lock_enabled", v and true or false)
    self:flush()
end

function Settings:getLockPin()
    return self:open():readSetting("lock_pin") or ""
end

function Settings:setLockPin(pin)
    self:open():saveSetting("lock_pin", pin or "")
    self:flush()
end

function Settings:getLockDimLevel()
    local d = self:open():readSetting("lock_dim_level")
    if type(d) ~= "number" or d < 1 or d > 4 then
        return 3
    end
    return d
end

function Settings:setLockDimLevel(level)
    level = math.max(1, math.min(4, math.floor(tonumber(level) or 3)))
    self:open():saveSetting("lock_dim_level", level)
    self:flush()
end

function Settings:isLockWarnSeen()
    return self:open():readSetting("lock_warn_seen") == true
end

function Settings:setLockWarnSeen()
    self:open():saveSetting("lock_warn_seen", true)
    self:flush()
end

return Settings
