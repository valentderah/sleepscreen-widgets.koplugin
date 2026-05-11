local M = {}

--- Outer width/height of a padded rectangle. Returns 0,0 if inner is invalid.
---@return integer ow, integer oh
function M.outer_size(inner_w, inner_h, pad_h, pad_v)
    inner_w = tonumber(inner_w)
    inner_h = tonumber(inner_h)
    if not inner_w or not inner_h or inner_w <= 0 or inner_h <= 0 then
        return 0, 0
    end
    pad_h = math.max(0, math.floor(tonumber(pad_h) or 0))
    local pv = tonumber(pad_v)
    if pv == nil then
        pv = pad_h
    end
    pv = math.max(0, math.floor(pv))
    return inner_w + 2 * pad_h, inner_h + 2 * pv
end

return M
