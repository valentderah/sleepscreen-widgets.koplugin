-- Run from repo root: lua tests/day_bounds_test.lua
package.path = package.path .. ";./?.lua"

local function assert_equal(actual, expected, msg)
    if actual ~= expected then
        error((msg or "assert_equal failed") .. ": got " .. tostring(actual) .. ", expected " .. tostring(expected))
    end
end

local bounds = assert(require("data.day_bounds"))

local noon = os.time({
    year = 2026,
    month = 5,
    day = 11,
    hour = 12,
    min = 0,
    sec = 0,
    isdst = -1,
})

local expected_midnight = os.time({
    year = 2026,
    month = 5,
    day = 11,
    hour = 0,
    min = 0,
    sec = 0,
    isdst = -1,
})

assert_equal(bounds.local_midnight_before_or_at(noon), expected_midnight)

print("day_bounds_test: OK")
