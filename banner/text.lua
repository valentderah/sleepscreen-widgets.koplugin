--[[ Shared text helpers for sleep banner blocks (KOReader). ]]
local BookInfo = require("apps/filemanager/filemanagerbookinfo")
local datetime = require("datetime")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local util = require("util")
local VerticalGroup = require("ui/widget/verticalgroup")

local BannerText = {}

function BannerText.expand_string(ui_for_bookinfo, pattern, last_file)
    if ui_for_bookinfo and ui_for_bookinfo.bookinfo then
        return ui_for_bookinfo.bookinfo:expandString(pattern, last_file)
    end
    return BookInfo:expandString(pattern, last_file)
end

function BannerText.addQuotesIfReq(text)
    if not text or text == "" then
        return text
    end
    local chars = util.splitToChars(text)
    local first_char = chars[1]
    local last_char = chars[#chars]
    local control = {
        { "'", "'" }, { '"', '"' }, { "“", "”" },
        { "‘", "’" }, { "«", "»" }, { "„", "“" },
    }
    local quotes_found = false
    for _, quotes in ipairs(control) do
        if first_char == quotes[1] and last_char == quotes[2] then
            quotes_found = true
            break
        end
    end
    if not quotes_found then
        return "“" .. text .. "”"
    end
    return text
end

function BannerText.parseFooterText(text, index, Sidecar)
    if not text or not index or text == "" then
        return text
    end

    local hl_array = Sidecar and Sidecar:readSetting("annotations")
    hl_array = hl_array and hl_array[index] or {}
    local hl_chapter = hl_array.chapter or "N/A"
    local hl_pageno = Sidecar and Sidecar:isTrue("pagemap_use_page_labels") and hl_array.pageref or hl_array.pageno or "N/A"

    local doc_props = Sidecar and Sidecar:readSetting("doc_props") or {}
    local bk_author = doc_props.authors or "N/A"
    local bk_title = doc_props.title or "N/A"

    local hl_date, yr, mth, dy
    local date_and_time = hl_array.datetime and util.splitToArray(hl_array.datetime, "%s+", false) or {}

    hl_date = date_and_time[1] or ""
    yr, mth, dy = hl_date:match("(%d+)-(%d+)-(%d+)")
    local month_abbr = yr and mth and dy and os.date("%b", os.time{ year = yr, month = mth, day = dy }) or ""
    local short_month = datetime.shortMonthTranslation[month_abbr] or ""
    hl_date = yr and mth and dy and short_month and string.format("%s %s '%02d", dy, short_month, tonumber(yr) % 100) or "N/A"

    local timesplit = date_and_time[2] and util.splitToArray(date_and_time[2], ":") or {}
    local hl_time = timesplit[1] and timesplit[2] and (timesplit[1] .. ":" .. timesplit[2]) or "N/A"

    local sub_table = {
        ["%%HM"] = hl_time,
        ["%%DT"] = hl_date,
        ["%%PG"] = hl_pageno,
        ["%%C"] = hl_chapter,
        ["%%A"] = bk_author,
        ["%%T"] = bk_title,
    }
    for pattern, replacement in pairs(sub_table) do
        if replacement then
            text = string.gsub(text, pattern, replacement)
        end
    end
    return text
end

function BannerText.buildTextField(B_SETT, HL_SETT, text, font_face, max_height, max_wid, ignoreLineBreaks, isHighlight, text_color)
    local Bb = require("ffi/blitbuffer")
    local wgt_grp = VerticalGroup:new{ align = "left" }
    text = text:gsub("\\n", "\n")
    local segments = ignoreLineBreaks and { text } or util.splitToArray(text, "\n")
    for _, item in ipairs(segments) do
        local wgt = TextWidget:new{
            padding = 0,
            text = item,
            face = font_face,
            alignment = "left",
            fgcolor = text_color or (B_SETT.background == 1 and Bb.COLOR_WHITE or Bb.COLOR_BLACK),
            bgcolor = B_SETT.background == 0 and Bb.COLOR_WHITE or Bb.COLOR_BLACK,
        }
        if wgt:getSize().w > max_wid then
            wgt:free()
            wgt = TextBoxWidget:new{
                text = item,
                face = font_face,
                width = max_wid,
                alignment = "left",
                height = max_height,
                height_adjust = true,
                height_overflow_show_ellipsis = true,
                justified = isHighlight and HL_SETT.justify,
                fgcolor = text_color or (B_SETT.background == 1 and Bb.COLOR_WHITE or Bb.COLOR_BLACK),
                bgcolor = B_SETT.background == 0 and Bb.COLOR_WHITE or Bb.COLOR_BLACK,
            }
        end
        table.insert(wgt_grp, wgt)
    end
    return wgt_grp
end

return BannerText
