local Device = require("device")
local FrameContainer = require("ui/widget/container/framecontainer")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local Screen = Device.screen
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local Config = require("config")
local FrameStyle = require("banner.frame_style")
local CellSlot = require("grid.cell_slot")
local GridGeometry = require("grid.grid_geometry")
local GridModel = require("grid.grid_model")
local Registry = require("banner.widgets.registry")
local SleepWidgetCard = require("grid.sleep_widget_card")
local SlotFillHolder = require("grid.slot_fill_holder")

local GridComposer = {}

local function default_span(type_id)
    Registry.ensure_registered()
    return Registry.default_col_span(type_id)
end

--- Resolve horizontal / vertical inset in dp (unscaled). Legacy `grid_edge_margin` fills
--- any axis that is not set in saved `banner`.
local inset_max = assert(
    tonumber(Config.GRID_EDGE_INSET_MAX),
    "config GRID_EDGE_INSET_MAX must be a positive number"
)
local DEF = Config.DEFAULT_BANNER
local LAYOUT = Config.GRID_LAYOUT

local function grid_edge_dp_x(B_SETT)
    local x = tonumber(B_SETT.grid_edge_margin_x)
    if x == nil then
        x = tonumber(B_SETT.grid_edge_margin)
    end
    if x == nil then
        x = tonumber(DEF.grid_edge_margin_x)
    end
    return math.max(0, math.min(inset_max, math.floor(x)))
end

local function grid_edge_dp_y(B_SETT)
    local y = tonumber(B_SETT.grid_edge_margin_y)
    if y == nil then
        y = tonumber(B_SETT.grid_edge_margin)
    end
    if y == nil then
        y = tonumber(DEF.grid_edge_margin_y)
    end
    return math.max(0, math.min(inset_max, math.floor(y)))
end

function GridComposer.compose(placements, ctx)
    Registry.ensure_registered()

    local B_SETT = ctx.B_SETT
    local edge_gap_x = Screen:scaleBySize(grid_edge_dp_x(B_SETT))
    local edge_gap_y = Screen:scaleBySize(grid_edge_dp_y(B_SETT))
    local inner_w = math.max(LAYOUT.inner_min_px, ctx.screen_w - 2 * edge_gap_x)
    local inner_h = math.max(LAYOUT.inner_min_px, (ctx.grid_inner_h or ctx.screen_h) - 2 * edge_gap_y)
    local grid_cols = GridModel.GRID_COLS
    local grid_rows = GridModel.GRID_ROWS
    local wg = B_SETT.widget_gap or DEF.widget_gap
    local gx = B_SETT.grid_gutter_x
    if gx == nil then gx = wg end
    local gy = B_SETT.grid_gutter_y
    if gy == nil then gy = wg end
    local gutter_x = Screen:scaleBySize(gx)
    local gutter_y = Screen:scaleBySize(gy)
    local slot_w, row_h = GridGeometry.slot_and_row_height(
        inner_w, inner_h, grid_cols, grid_rows, gutter_x, gutter_y
    )

    local card_pad = Screen:scaleBySize(B_SETT.widget_padding or DEF.widget_padding)
    local card_r = Screen:scaleBySize(B_SETT.widget_radius or DEF.widget_radius)

    local resolved = GridModel.placementsWithSpan(placements or {}, default_span)
    local by_row = {}
    for r = 1, grid_rows do
        by_row[r] = {}
    end
    for _, p in ipairs(resolved) do
        if p.row >= 1 and p.row <= grid_rows then
            table.insert(by_row[p.row], p)
        end
    end
    for r = 1, grid_rows do
        table.sort(by_row[r], function(a, b)
            return a.col < b.col
        end)
    end

    local function starts_for_row(r)
        local m = {}
        for _, p in ipairs(by_row[r]) do
            m[p.col] = p
        end
        return m
    end

    local function build_cell(block, cw, ch, zone_tag, col_span)
        local col = VerticalGroup:new{ align = "center" }
        if not block then
            table.insert(col, VerticalSpan:new{ width = 1 })
        else
            local content_w = math.max(0, cw - 2 * card_pad)
            local content_h = math.max(0, ch - 2 * card_pad)
            local span = tonumber(col_span) or 1
            if span ~= 2 and span ~= 3 then
                span = 1
            end
            ctx.col_span = span
            ctx.cell_w = cw
            ctx.cell_h = ch
            ctx.cell_max_w = math.max(LAYOUT.cell_content_min_px, content_w)
            ctx.cell_max_h = math.max(LAYOUT.cell_content_min_px, content_h)
            ctx.zone_index = zone_tag
            local card_palette = block.type == "calendar_tile"
                and FrameStyle.card_colors_dark_tile()
                or FrameStyle.card_colors_light()
            ctx.card_palette = card_palette
            local w = Registry.build(block, ctx)
            if w then
                local holder = SlotFillHolder:new{
                    inner_w = content_w,
                    inner_h = content_h,
                    w,
                }
                table.insert(col, SleepWidgetCard:new{
                    B_SETT = B_SETT,
                    radius = card_r,
                    pad_h = card_pad,
                    pad_v = card_pad,
                    palette = card_palette,
                    holder,
                })
            else
                table.insert(col, VerticalSpan:new{ width = 1 })
            end
        end
        local inner = FrameContainer:new{
            background = nil,
            bordersize = 0,
            padding = 0,
            margin = 0,
            VerticalGroup:new{
                align = "center",
                col,
            },
        }
        return CellSlot:new{
            slot_w = cw,
            slot_h = ch,
            inner,
        }
    end

    local rows_group = VerticalGroup:new{ align = "center" }
    for r = 1, grid_rows do
        local row_group = HorizontalGroup:new{ align = "center" }
        local starts = starts_for_row(r)
        local col = 1
        while col <= grid_cols do
            local p = starts[col]
            if p then
                local span = p.span or 1
                local mw = GridGeometry.merged_span_width(slot_w, gutter_x, span)
                local block = { type = p.type, params = p.params }
                local zone_tag = r * LAYOUT.zone_tag_row_multiplier + p.col
                table.insert(row_group, build_cell(block, mw, row_h, zone_tag, span))
                col = col + span
            else
                table.insert(row_group, build_cell(nil, slot_w, row_h, r * LAYOUT.zone_tag_row_multiplier + col, 1))
                col = col + 1
            end
            if col <= grid_cols then
                table.insert(row_group, HorizontalSpan:new{ width = gutter_x })
            end
        end
        table.insert(rows_group, row_group)
        if r < grid_rows then
            table.insert(rows_group, VerticalSpan:new{ width = gutter_y })
        end
    end

    -- FrameContainer margin is a single scalar in KOReader; asymmetric insets use spans.
    local h_padded = HorizontalGroup:new{
        align = "center",
        HorizontalSpan:new{ width = edge_gap_x },
        rows_group,
        HorizontalSpan:new{ width = edge_gap_x },
    }
    local root_content = VerticalGroup:new{
        align = "center",
        VerticalSpan:new{ width = edge_gap_y },
        h_padded,
        VerticalSpan:new{ width = edge_gap_y },
    }
    return FrameContainer:new{
        background = nil,
        bordersize = 0,
        margin = 0,
        padding = 0,
        root_content,
    }
end

return GridComposer
