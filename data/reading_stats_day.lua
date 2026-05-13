local lfs = require("libs/libkoreader-lfs")
local logger = require("logger")
local day_bounds = require("data.day_bounds")

-- Schema/source of truth for page_stat: KOReader upstream plugins/statistics.koplugin/main.lua (SQLite + CREATE VIEW).

local M = {}

function M.total_seconds_today()
    local path = require("datastorage"):getSettingsDir() .. "/statistics.sqlite3"
    if lfs.attributes(path, "mode") ~= "file" then
        return nil, "no_db"
    end

    local since = day_bounds.local_midnight_before_or_at()

    local ok_sq, SQ3 = pcall(require, "lua-ljsqlite3/init")
    if not ok_sq or not SQ3 then
        return nil, "no_sqlite"
    end

    local ok_open, conn = pcall(SQ3.open, path)
    if not ok_open or not conn then
        return nil, "open_failed"
    end

    local sql = string.format(
        "SELECT COALESCE(SUM(duration), 0) FROM page_stat WHERE start_time >= %d",
        math.floor(tonumber(since) or 0)
    )

    local ok_q, sum = pcall(function()
        return conn:rowexec(sql)
    end)

    pcall(function()
        conn:close()
    end)

    if not ok_q then
        logger.warn("sleepscreen_widgets", "reading_stats_day: query failed")
        return nil, "query_failed"
    end

    local n = tonumber(sum) or 0
    if n < 0 then
        n = 0
    end

    return n, nil
end

return M
