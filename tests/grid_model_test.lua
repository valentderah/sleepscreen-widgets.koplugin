-- Run from repo root: lua tests/grid_model_test.lua
package.path = package.path .. ";./?.lua"

local function assert_eq(a, b, m)
    if a ~= b then
        error((m or "eq") .. ": " .. tostring(a) .. " vs " .. tostring(b))
    end
end

local GM = assert(require("grid.grid_model"))

local function mock_default(t)
    if t == "wide" then
        return 3
    end
    return 1
end

local function def1(_)
    return 1
end

-- migrate legacy 9-stack
local legacy = {
    { { type = "clock", params = {} } },
    {}, {},
    {}, {}, {},
    {}, {}, {},
}
local p = GM.parseSaved(legacy, def1)
assert_eq(#p, 1)
assert_eq(p[1].type, "clock")
assert_eq(p[1].row, 1)
assert_eq(p[1].col, 1)
print("grid_model_test migrate: OK")

-- dedupe: two at same anchor
local dup = {
    { type = "clock", params = {}, row = 1, col = 1 },
    { type = "battery_status", params = {}, row = 1, col = 1 },
}
local p2 = GM.normalizePlacements(dup, def1)
assert_eq(#p2, 1)
assert_eq(p2[1].type, "clock")
print("grid_model_test dedupe: OK")

-- wide default span 3 occupies row 1; second widget dropped
local wide = {
    { type = "wide", params = {}, row = 1, col = 1 },
    { type = "clock", params = {}, row = 1, col = 2 },
}
local p3 = GM.normalizePlacements(wide, mock_default)
assert_eq(#p3, 1)
assert_eq(p3[1].type, "wide")
assert_eq(GM.resolveColSpan(p3[1].type, p3[1].params, p3[1].row, p3[1].col, mock_default), 3)
print("grid_model_test wide span: OK")
