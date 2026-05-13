local Device = require("device")
local Font = require("ui/font")
local Geom = require("ui/geometry")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local LineWidget = require("ui/widget/linewidget")
local Screen = Device.screen
local Size = require("ui/size")
local util = require("util")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")

local BannerText = require("banner.text")
local FrameStyle = require("banner.frame_style")

local cached_random_highlight_index = 1

local M = {}

function M.register(Registry)
    Registry.register("highlight", function(params, ctx)
        local B_SETT = ctx.B_SETT
        local HL_SETT = {}
        util.tableMerge(HL_SETT, ctx.HL_SETT)
        util.tableMerge(HL_SETT, params)
        HL_SETT.allowed_hl_styles = HL_SETT.allowed_hl_styles or ctx.HL_SETT.allowed_hl_styles

        local Sidecar = ctx.Sidecar
        local highlights_list = {}
        local all_annotations = Sidecar and Sidecar:readSetting("annotations") or {}
        local allowed = HL_SETT.allowed_hl_styles or {}
        for _, item in ipairs(all_annotations) do
            if item.text and item.drawer and allowed[item.drawer] then
                local trimmed = util.trim(item.text)
                if trimmed ~= "" then
                    table.insert(highlights_list, item)
                end
            end
        end
        local highlight_count = #highlights_list
        if highlight_count == 0 then
            return VerticalSpan:new{ width = 1 }
        end

        local footer_font = Font:getFace(HL_SETT.hl_footer_fontFace, HL_SETT.hl_footer_fontSize)
            or Font:getFace("NotoSerif-Regular.ttf", 15)
        local highlight_font = Font:getFace(HL_SETT.highlight_fontFace, HL_SETT.highlight_fontSize)
            or Font:getFace("NotoSerif-Italic.ttf", 16)

        local random_highlight_index
        local random_highlight
        if highlight_count == 1 then
            random_highlight = highlights_list[1] and highlights_list[1].text or ""
            random_highlight_index = 1
        else
            random_highlight_index = math.random(highlight_count)
            while random_highlight_index == cached_random_highlight_index do
                random_highlight_index = math.random(highlight_count)
            end
            cached_random_highlight_index = random_highlight_index
            random_highlight = highlights_list[random_highlight_index] and highlights_list[random_highlight_index].text or ""
        end

        random_highlight = util.trim(random_highlight)
        random_highlight = HL_SETT.add_quotations and BannerText.addQuotesIfReq(random_highlight) or random_highlight

        local pal = ctx.card_palette or FrameStyle.card_colors_light()

        local footer_color = pal.text_secondary

        local footer_tpl = HL_SETT.hl_footer_text or ""
        local hl_footer_enabled = HL_SETT.showHighlightFooter
            and footer_tpl
            and util.trim(footer_tpl) ~= ""

        local hl_footer_widget
        if hl_footer_enabled then
            local hyphen_wid = BannerText.buildTextField(B_SETT, HL_SETT, "— ", footer_font, ctx.cell_max_h, ctx.cell_max_w, true, false, footer_color, pal.fill)
            local hyphen_tw = hyphen_wid:getSize().w
            local footer_w_budget = math.max(40, (ctx.cell_max_w or 100) - hyphen_tw)
            hl_footer_widget = BannerText.buildTextField(
                B_SETT,
                HL_SETT,
                BannerText.parseFooterText(footer_tpl, random_highlight_index, Sidecar),
                footer_font,
                ctx.cell_max_h,
                footer_w_budget,
                false,
                false,
                footer_color,
                pal.fill
            )
            hl_footer_widget = HorizontalGroup:new{
                align = "top",
                hyphen_wid,
                hl_footer_widget,
            }
            hl_footer_widget = VerticalGroup:new{
                VerticalSpan:new{ width = Size.padding.large },
                hl_footer_widget,
            }
        end

        local hl_wgt_max_h = hl_footer_enabled
                and (ctx.cell_max_h - hl_footer_widget:getSize().h)
            or ctx.cell_max_h

        local accent_w = HL_SETT.show_accent_line and Screen:scaleBySize(1) or 0
        local accent_gap = HL_SETT.show_accent_line and Size.padding.large or 0
        local quote_w = math.max(40, (ctx.cell_max_w or 100) - accent_w - accent_gap)

        local highlight_widget = BannerText.buildTextField(
            B_SETT,
            HL_SETT,
            random_highlight,
            highlight_font,
            hl_wgt_max_h,
            quote_w,
            true,
            true,
            pal.text_primary,
            pal.fill,
            { force_full_width = true }
        )
        local accent_height = highlight_widget:getSize().h

        if HL_SETT.show_accent_line then
            local highlight_accent = LineWidget:new{
                background = footer_color,
                dimen = Geom:new{
                    w = Screen:scaleBySize(1),
                    h = accent_height,
                },
            }
            highlight_widget = HorizontalGroup:new{
                align = "top",
                highlight_accent,
                HorizontalSpan:new{ width = Size.padding.large },
                highlight_widget,
            }
        end

        if hl_footer_enabled and hl_footer_widget then
            highlight_widget = VerticalGroup:new{
                align = "left",
                highlight_widget,
                hl_footer_widget,
            }
        end

        return highlight_widget
    end)
end

return M
