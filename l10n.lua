--[[ Localization for awesome-sleepscreen plugin (en msgids + ru + zh_CN .po). ]]
local logger = require("logger")
local gettext = require("gettext")

local M = {}

local plugin_root = (debug.getinfo(1, "S").source:match("^@(.+)/") or "."):gsub("/+$", "")
local translations = {}

local function parse_po(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local map = {}
    local msgid, msgstr
    local in_id, in_str = false, false

    local function flush()
        if msgid and msgstr and msgid ~= "" and msgstr ~= "" then
            map[msgid] = msgstr
        end
        msgid, msgstr = nil, nil
        in_id, in_str = false, false
    end

    local function unescape(s)
        return s:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub('\\"', '"'):gsub("\\\\", "\\")
    end

    for raw_line in f:lines() do
        local line = raw_line:match("^%s*(.-)%s*$")
        if line:match("^#") or line == "" then
            if line == "" then flush() end
        elseif line:match('^msgid%s+"') then
            flush()
            msgid = unescape(line:match('^msgid%s+"(.*)"') or "")
            in_id, in_str = true, false
        elseif line:match('^msgstr%s+"') then
            msgstr = unescape(line:match('^msgstr%s+"(.*)"') or "")
            in_str, in_id = true, false
        elseif line:match('^"') then
            local cont = unescape(line:match('^"(.*)"') or "")
            if in_id and msgid then msgid = msgid .. cont end
            if in_str and msgstr then msgstr = msgstr .. cont end
        end
    end
    flush()
    f:close()
    return map
end

local function lang_to_po_subdir(lang)
    if not lang or lang == "" or lang == "en" or lang == "en_US" then
        return nil
    end
    if lang == "ru" or lang == "ru_RU" then
        return "ru"
    end
    if lang == "zh_CN" or lang == "zh" then
        return "zh_CN"
    end
    if lang == "zh_TW" then
        return nil
    end
    return nil
end

function M.load()
    translations = {}
    local lang = G_reader_settings and G_reader_settings:readSetting("language") or "en"
    local sub = lang_to_po_subdir(lang)
    if not sub then return end
    local path = plugin_root .. "/l10n/" .. sub .. "/awesome_sleepscreen.po"
    local map = parse_po(path)
    if map and next(map) then
        translations = map
        local n = 0
        for _ in pairs(map) do n = n + 1 end
        logger.info("awesome_sleepscreen l10n: loaded " .. path .. " (" .. n .. " strings)")
    end
end

function M.gettext(msgid)
    local tr = translations[msgid]
    if tr and tr ~= "" then return tr end
    return gettext(msgid)
end

function M.ngettext(msgid, msgid_plural, n)
    if gettext.ngettext then
        return gettext.ngettext(msgid, msgid_plural, n)
    end
    return n == 1 and msgid or msgid_plural
end

return M
