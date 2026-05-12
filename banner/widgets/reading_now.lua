local Device = require("device")
local Font = require("ui/font")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local ProgressWidget = require("ui/widget/progresswidget")
local Screen = Device.screen
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local FrameStyle = require("banner.frame_style")

local _ = require("l10n").gettext

local M = {}

function M.register(Registry)
    Registry.register("reading_now", function(_params, ctx)
        local max_w = ctx.cell_max_w or 100
        local pal = ctx.card_palette or FrameStyle.card_colors_light()
        local ui = ctx.ui_inst

        if not ui or not ui.document then
            return TextBoxWidget:new{
                text = _("No book open"),
                face = Font:getFace("cfont", 14),
                width = max_w,
                fgcolor = pal.text_secondary,
                alignment = "center",
            }
        end

        local doc_props = ui.doc_props or {}
        local title = doc_props.display_title or doc_props.title or ""
        local author = doc_props.authors or ""
        if type(author) == "string" and author:find("\n") then
            local util = require("util")
            local authors = util.splitToArray(author, "\n")
            author = authors[1] or author
        end

        local page = 1
        local total = 1
        if ui.view and ui.view.state and ui.view.state.page then
            page = ui.view.state.page
        end
        local doc_settings = ui.doc_settings and ui.doc_settings.data or {}
        total = tonumber(doc_settings.doc_pages) or 1
        if total <= 0 then
            total = 1
        end
        page = math.max(1, math.min(page, total))

        local pct = math.max(0, math.min(1, page / total))
        local pct_txt = string.format("%d%%", math.floor(pct * 100 + 0.5))

        if title == "" then
            title = _("Untitled")
        end

        local col = VerticalGroup:new{ align = "left" }

        local pct_widget = TextWidget:new{
            text = pct_txt,
            face = Font:getFace("cfont", 14),
            fgcolor = pal.text_secondary,
            padding = 0,
        }
        local title_width = math.max(40, max_w - pct_widget:getSize().w - Screen:scaleBySize(4))
        local title_box = TextBoxWidget:new{
            text = title,
            face = Font:getFace("cfont", 16),
            width = title_width,
            fgcolor = pal.text_primary,
            bold = true,
        }
        local head = HorizontalGroup:new{}
        table.insert(head, title_box)
        local span_w = math.max(0, max_w - title_box:getSize().w - pct_widget:getSize().w)
        table.insert(head, HorizontalSpan:new{ width = span_w })
        table.insert(head, pct_widget)
        table.insert(col, head)

        if author ~= "" then
            table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(2) })
            table.insert(col, TextBoxWidget:new{
                text = author,
                face = Font:getFace("cfont", 13),
                width = max_w,
                fgcolor = pal.text_secondary,
            })
        end

        table.insert(col, VerticalSpan:new{ width = Screen:scaleBySize(6) })
        table.insert(col, ProgressWidget:new{
            width = max_w,
            height = Screen:scaleBySize(10),
            percentage = pct,
            margin_v = 0,
            margin_h = 0,
            radius = Screen:scaleBySize(4),
            bordersize = 0,
            bgcolor = pal.progress_track,
            fillcolor = pal.progress_fill,
        })
        return col
    end)
end

return M
