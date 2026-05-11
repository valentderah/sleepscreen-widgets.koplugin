local Device = require("device")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local Screen = Device.screen
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local Registry = require("banner.blocks.registry")
local SleepBlockCard = require("grid.sleep_block_card")

local GridComposer = {}

function GridComposer.compose(zones, ctx)
    Registry.ensure_registered()

    local B_SETT = ctx.B_SETT
    -- Edge gap keeps cards slightly away from screen border; all other chrome removed.
    local edge_gap = Screen:scaleBySize(6)
    local inner_w = ctx.screen_w - 2 * edge_gap
    local inner_h = ctx.grid_inner_h or ctx.screen_h
    local cell_w = math.max(10, math.floor(inner_w / 3))
    local cell_h = math.max(10, math.floor(inner_h / 3))
    local card_pad = Screen:scaleBySize(B_SETT.widget_padding or 8)
    ctx.cell_max_w = math.max(20, cell_w - card_pad * 2)
    ctx.cell_max_h = math.max(20, cell_h - card_pad * 2)

    local function cell_stack(zone_idx)
        local stack = zones[zone_idx] or {}
        local col = VerticalGroup:new{ align = "center" }
        local gap = Screen:scaleBySize(B_SETT.widget_gap or 6)
        local card_r = Screen:scaleBySize(B_SETT.widget_radius or 12)
        if #stack == 0 then
            table.insert(col, VerticalSpan:new{ width = 1 })
        else
            local first_card = true
            for _, block in ipairs(stack) do
                local w = Registry.build(block, ctx)
                if w then
                    if not first_card then
                        table.insert(col, VerticalSpan:new{ width = gap })
                    end
                    first_card = false
                    table.insert(col, SleepBlockCard:new{
                        B_SETT = B_SETT,
                        radius = card_r,
                        pad_h = card_pad,
                        pad_v = card_pad,
                        w,
                    })
                end
            end
            if #col == 0 then
                table.insert(col, VerticalSpan:new{ width = 1 })
            end
        end
        -- Transparent cell container — cards paint their own background.
        return FrameContainer:new{
            background = nil,
            bordersize = 0,
            padding = 0,
            margin = 0,
            dimen = Geom:new{ w = cell_w, h = cell_h },
            VerticalGroup:new{
                align = "center",
                col,
            },
        }
    end

    local rows = VerticalGroup:new{ align = "center" }
    for r = 0, 2 do
        local row = HorizontalGroup:new{ align = "center" }
        for c = 1, 3 do
            local idx = r * 3 + c
            table.insert(row, cell_stack(idx))
        end
        table.insert(rows, row)
    end

    -- Outer container is also transparent; edge_gap provides a small margin around the grid.
    return FrameContainer:new{
        background = nil,
        bordersize = 0,
        margin = edge_gap,
        padding = 0,
        rows,
    }
end

return GridComposer
