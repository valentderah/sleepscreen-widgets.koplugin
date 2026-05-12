-- Pure Lua (no KOReader requires). Used for statistics day window.
local M = {}

--- @param now number|nil unix seconds; default os.time()
--- @return number unix seconds at local midnight for the same calendar day as `now`
function M.local_midnight_before_or_at(now)
    now = now or os.time()
    local t = os.date("*t", now)
    t.hour = 0
    t.min = 0
    t.sec = 0
    return os.time(t)
end

return M
