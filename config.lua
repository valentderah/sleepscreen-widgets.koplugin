--[[ Defaults for awesome-sleepscreen plugin. ]]
local Config = {}

--- Bump when persisted settings shape changes; `Settings:open` re-writes `grid` from v2 or clears to empty.
Config.SCHEMA_VERSION = 7

Config.GRID_EDGE_INSET_MAX = 512

--- Composer geometry (screen px before scale where noted; see also DEFAULT_BANNER).
Config.GRID_LAYOUT = {
    --- Minimum inner width/height used for slot math after edge insets.
    inner_min_px = 30,
    --- Minimum square side / span≥2 content box (after card padding).
    cell_content_min_px = 20,
    --- zone_index encoding: row * factor + anchor_col (see grid_editor if changed).
    zone_tag_row_multiplier = 10,
}

--- Clamps for Banner appearance menu (logical px unless noted).
Config.UI_LIMITS = {
    widget_radius_px = { max = 48 },
    widget_padding_px = { max = 32 },
    widget_gap_px = { max = 24 },
}

--- Initial grid when `grid` is absent from settings (first open). Grid is 3 cols × 6 rows (see GridModel).
Config.DEFAULT_GRID_PLACEMENTS = {
    { type = "header_datetime", params = {}, row = 1, col = 1 },
    { type = "reading_now", params = { col_span = 3 }, row = 2, col = 1 },
    { type = "today_reading", params = { daily_goal_minutes = 60 }, row = 3, col = 1 },
    { type = "battery_status", params = {}, row = 3, col = 2 },
    { type = "calendar_tile", params = {}, row = 3, col = 3 },
    { type = "highlight", params = { col_span = 3 }, row = 4, col = 1 },
}

Config.DEFAULT_BANNER = {
    title_fontFace = "cfont",
    title_fontSize = 30,
    stats_fontFace = "cfont",
    stats_fontSize = 17,
    background = 0,
    widget_radius = 12,
    widget_padding = 8,
    widget_gap = 6,
    grid_edge_margin_x = 100,
    grid_edge_margin_y = 100,
}

Config.DEFAULT_HIGHLIGHT = {
    showRandomHighlight = true,
    highlight_fontFace = "NotoSerif-Italic.ttf",
    highlight_fontSize = 16,
    justify = true,
    add_quotations = true,
    show_accent_line = true,
    showHighlightFooter = true,
    hl_footer_fontFace = "NotoSerif-Regular.ttf",
    hl_footer_fontSize = 15,
    hl_footer_text = "saved on %DT at %HM",
    allowed_hl_styles = {
        lighten = true,
        underscore = true,
        strikethrough = false,
        invert = false,
    },
}

return Config
