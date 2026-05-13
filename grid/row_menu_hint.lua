--[[ Pure helpers for TouchMenu row summary (spec §4). ]]
local GridModel = require("grid.grid_model")

local M = {}

local EMPTY = "—"
local OCCUPIED = "·"

--- One column token: widget type at anchor, OCCUPIED if covered by neighbor span, EMPTY if free.
function M.cell_token(placements, row, col, default_fn)
    default_fn = default_fn or function() return 1 end
    if type(placements) ~= "table" or type(row) ~= "number" or type(col) ~= "number" then
        return EMPTY
    end
    for _, p in ipairs(placements) do
        if type(p) == "table" and type(p.type) == "string" and p.type ~= "" then
            local span = GridModel.resolveColSpan(p.type, p.params, p.row, p.col, default_fn)
            if p.row == row and col >= p.col and col < p.col + span then
                if p.col == col then
                    return p.type
                end
                return OCCUPIED
            end
        end
    end
    return EMPTY
end

--- "type1 · type2 · type3" for columns 1..3
function M.row_hint(placements, row, default_fn)
    local a = M.cell_token(placements, row, 1, default_fn)
    local b = M.cell_token(placements, row, 2, default_fn)
    local c = M.cell_token(placements, row, 3, default_fn)
    return a .. " · " .. b .. " · " .. c
end

return M
