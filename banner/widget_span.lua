--[[ Helpers for sleep banner widgets: column span from ctx, font scaling. ]]
local M = {}

function M.col_span(ctx)
    local s = ctx and tonumber(ctx.col_span)
    if s == 2 or s == 3 then
        return s
    end
    return 1
end

--- Slightly smaller type in 2–3 column slots to reduce clipping (spec §2).
function M.scaled_font_size(base_size, ctx)
    local n = tonumber(base_size) or 20
    if M.col_span(ctx) >= 2 then
        n = math.max(10, math.floor(n * 0.88 + 0.5))
    end
    return n
end

return M
