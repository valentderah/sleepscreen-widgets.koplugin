--[[ Defaults for awesome-sleepscreen plugin (no preset migrations). ]]
local Config = {}

Config.SCHEMA_VERSION = 6
-- `lock_*` settings were removed at schema revision 5 (PIN / wake lock feature dropped).
Config.SCHEMA_LOCK_KEYS_REMOVED_AT = 5
-- Grid layout migrated from 9 stacked zones to 6×3 placements at revision 6.
Config.SCHEMA_GRID_PLACEMENTS_AT = 6

Config.DEFAULT_BANNER = {
    title_fontFace = "cfont",
    title_fontSize = 30,
    stats_fontFace = "cfont",
    stats_fontSize = 17,
    border_size = 1,
    border_color = 0,
    background = 0,
    margin = 10,
    padding = 15,
    max_height = 95,
    max_width_hl_off = 40,
    max_width_hl_on = 60,
    widget_radius = 12,
    widget_padding = 8,
    widget_gap = 6,
    grid_gutter_x = nil,
    grid_gutter_y = nil,
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
