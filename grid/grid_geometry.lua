local M = {}

--- @param inner_w integer drawable width inside edge margins
--- @param inner_h integer total grid height
--- @param grid_cols integer
--- @param grid_rows integer
--- @param gutter_x integer horizontal gap between columns (count = grid_cols - 1)
--- @param gutter_y integer vertical gap between rows (count = grid_rows - 1)
function M.slot_and_row_height(inner_w, inner_h, grid_cols, grid_rows, gutter_x, gutter_y)
    grid_cols = math.max(1, grid_cols)
    grid_rows = math.max(1, grid_rows)
    gutter_x = math.max(0, gutter_x)
    gutter_y = math.max(0, gutter_y)
    local inner_cols = inner_w - (grid_cols - 1) * gutter_x
    local inner_rows = inner_h - (grid_rows - 1) * gutter_y
    local slot_w = math.max(1, math.floor(inner_cols / grid_cols))
    local row_h = math.max(1, math.floor(inner_rows / grid_rows))
    return slot_w, row_h
end

function M.merged_span_width(slot_w, gutter_x, col_span)
    col_span = math.max(1, col_span)
    return col_span * slot_w + (col_span - 1) * gutter_x
end

return M
