--[[ Placements for 6×3 grid (pure Lua, KOReader-agnostic). ]]
local GridModel = {}

GridModel.GRID_COLS = 3
GridModel.GRID_ROWS = 6
GridModel.SLOT_COUNT = GridModel.GRID_COLS * GridModel.GRID_ROWS
GridModel.LEGACY_STACK_COUNT = 9
GridModel.ZONE_COUNT = GridModel.SLOT_COUNT

function GridModel.normalizeWidget(block)
    if type(block) ~= "table" or type(block.type) ~= "string" or block.type == "" then
        return nil
    end
    local params = block.params
    if type(params) ~= "table" then
        params = {}
    end
    return { type = block.type, params = params }
end

GridModel.normalizeBlock = GridModel.normalizeWidget

function GridModel.maxSpanForCol(col)
    col = tonumber(col) or 0
    if col <= 1 then return 3 end
    if col == 2 then return 2 end
    return 1
end

function GridModel.resolveColSpan(widget_type, params, row, col, default_fn)
    default_fn = default_fn or function() return 1 end
    local max_s = GridModel.maxSpanForCol(col)
    local ps = params
    if type(ps) ~= "table" then ps = {} end
    local function clamp_span(s)
        s = tonumber(s)
        if s ~= 1 and s ~= 2 and s ~= 3 then return nil end
        return math.min(s, max_s)
    end
    local from_params = clamp_span(ps.col_span)
    if from_params then
        return from_params
    end
    local d = tonumber(default_fn(widget_type)) or 1
    if d ~= 2 and d ~= 3 then
        d = 1
    end
    return math.min(d, max_s)
end

local function normalizePlacementEntry(e, default_fn)
    local row = tonumber(e.row)
    local col = tonumber(e.col)
    if not row or not col then
        return nil
    end
    if row < 1 or row > GridModel.GRID_ROWS or col < 1 or col > GridModel.GRID_COLS then
        return nil
    end
    local w = GridModel.normalizeWidget({ type = e.type, params = e.params })
    if not w then
        return nil
    end
    local span = GridModel.resolveColSpan(w.type, w.params, row, col, default_fn)
    return {
        type = w.type,
        params = w.params,
        row = row,
        col = col,
        _span = span,
    }
end

function GridModel.normalizePlacements(raw_list, default_fn)
    default_fn = default_fn or function() return 1 end
    local tmp = {}
    if type(raw_list) ~= "table" then
        return {}
    end
    for _, e in ipairs(raw_list) do
        local p = normalizePlacementEntry(e, default_fn)
        if p then
            table.insert(tmp, p)
        end
    end
    table.sort(tmp, function(a, b)
        if a.row ~= b.row then
            return a.row < b.row
        end
        return a.col < b.col
    end)
    local occ = {}
    for r = 1, GridModel.GRID_ROWS do
        occ[r] = { false, false, false }
    end
    local out = {}
    for _, p in ipairs(tmp) do
        local span = p._span
        local ok = true
        for dc = 0, span - 1 do
            local c = p.col + dc
            if c > GridModel.GRID_COLS or occ[p.row][c] then
                ok = false
                break
            end
        end
        if ok then
            for dc = 0, span - 1 do
                occ[p.row][p.col + dc] = true
            end
            table.insert(out, { type = p.type, params = p.params, row = p.row, col = p.col })
        end
    end
    return out
end

function GridModel.isLegacyStackGrid(raw)
    if type(raw) ~= "table" or raw.format_version == 2 then
        return false
    end
    if #raw ~= GridModel.LEGACY_STACK_COUNT then
        return false
    end
    for i = 1, GridModel.LEGACY_STACK_COUNT do
        if type(raw[i]) ~= "table" then
            return false
        end
    end
    return true
end

function GridModel.migrateLegacyStackGrid(raw, default_fn)
    local list = {}
    for i = 1, GridModel.LEGACY_STACK_COUNT do
        local stack = raw[i]
        if type(stack) == "table" then
            for _, b in ipairs(stack) do
                local w = GridModel.normalizeWidget(b)
                if w then
                    local row = math.floor((i - 1) / 3) + 1
                    local col = (i - 1) % 3 + 1
                    table.insert(list, {
                        type = w.type,
                        params = w.params,
                        row = row,
                        col = col,
                    })
                    break
                end
            end
        end
    end
    return GridModel.normalizePlacements(list, default_fn)
end

function GridModel.wrapSaved(placements)
    return { format_version = 2, placements = placements or {} }
end

function GridModel.emptySaved()
    return GridModel.wrapSaved({})
end

function GridModel.parseSaved(blob, default_fn)
    default_fn = default_fn or function() return 1 end
    if type(blob) == "table" and blob.format_version == 2 and type(blob.placements) == "table" then
        return GridModel.normalizePlacements(blob.placements, default_fn)
    end
    if GridModel.isLegacyStackGrid(blob) then
        return GridModel.migrateLegacyStackGrid(blob, default_fn)
    end
    return {}
end

function GridModel.placementsWithSpan(list, default_fn)
    default_fn = default_fn or function() return 1 end
    local out = {}
    if type(list) ~= "table" then
        return out
    end
    for _, p in ipairs(list) do
        local span = GridModel.resolveColSpan(p.type, p.params, p.row, p.col, default_fn)
        table.insert(out, {
            type = p.type,
            params = p.params,
            row = p.row,
            col = p.col,
            span = span,
        })
    end
    return out
end

return GridModel
