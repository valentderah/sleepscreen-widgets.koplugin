--[[ Pure helpers for 9-zone grid (no KOReader API). ]]
local GridModel = {}

GridModel.ZONE_COUNT = 9

function GridModel.emptyZones()
    local z = {}
    for i = 1, GridModel.ZONE_COUNT do
        z[i] = {}
    end
    return z
end

function GridModel.normalizeBlock(block)
    if type(block) ~= "table" or type(block.type) ~= "string" or block.type == "" then
        return nil
    end
    local params = block.params
    if type(params) ~= "table" then
        params = {}
    end
    return { type = block.type, params = params }
end

function GridModel.normalizeZones(saved_zones)
    local out = GridModel.emptyZones()
    if type(saved_zones) ~= "table" then
        return out
    end
    for i = 1, GridModel.ZONE_COUNT do
        local stack = saved_zones[i]
        out[i] = {}
        if type(stack) == "table" then
            for _, b in ipairs(stack) do
                local nb = GridModel.normalizeBlock(b)
                if nb then
                    table.insert(out[i], nb)
                end
            end
        end
    end
    return out
end

return GridModel
