--[[ Zone / block editing via nested TouchMenu tables. ]]
local InfoMessage = require("ui/widget/infomessage")
local InputDialog = require("ui/widget/inputdialog")
local UIManager = require("ui/uimanager")

local Settings = require("settings")

local _ = require("l10n").gettext

local GridEditor = {}

local function default_block(block_type)
    if block_type == "template" then
        return { type = "template", params = { pattern = "%T", role = "title" } }
    elseif block_type == "sleep_stats" then
        return { type = "sleep_stats", params = { mode = "stock", role = "stats" } }
    elseif block_type == "highlight" then
        return { type = "highlight", params = {} }
    elseif block_type == "clock" then
        return { type = "clock", params = { format = "%H:%M", font_face = "cfont", font_size = 22 } }
    elseif block_type == "clock_analog" then
        return { type = "clock_analog", params = { diameter_pct = 100 } }
    end
    return { type = block_type, params = {} }
end

local function save_zones(zones)
    Settings:saveGridZones(zones)
end

function GridEditor.addBlockMenu(zone_idx)
    return {
        {
            text = _("Text template"),
            callback = function()
                local zones = Settings:getGridZones()
                table.insert(zones[zone_idx], default_block("template"))
                save_zones(zones)
            end,
        },
        {
            text = _("Sleep stats line"),
            callback = function()
                local zones = Settings:getGridZones()
                table.insert(zones[zone_idx], default_block("sleep_stats"))
                save_zones(zones)
            end,
        },
        {
            text = _("Random highlight"),
            callback = function()
                local zones = Settings:getGridZones()
                table.insert(zones[zone_idx], default_block("highlight"))
                save_zones(zones)
            end,
        },
        {
            text = _("Clock"),
            callback = function()
                local zones = Settings:getGridZones()
                table.insert(zones[zone_idx], default_block("clock"))
                save_zones(zones)
            end,
        },
        {
            text = _("Analog clock"),
            callback = function()
                local zones = Settings:getGridZones()
                table.insert(zones[zone_idx], default_block("clock_analog"))
                save_zones(zones)
            end,
        },
    }
end

function GridEditor.blockMenu(zone_idx, block_idx)
    local zones = Settings:getGridZones()
    local block = zones[zone_idx] and zones[zone_idx][block_idx]
    if not block then
        return {}
    end
    local items = {}

    if block.type == "template" then
        table.insert(items, {
            text = _("Edit template pattern…"),
            callback = function()
                local dlg
                dlg = InputDialog:new{
                    title = _("Template"),
                    input = block.params.pattern or "",
                    input_hint = _("%T %c …"),
                    buttons = {{
                        {
                            text = _("Cancel"),
                            callback = function()
                                UIManager:close(dlg)
                            end,
                        },
                        {
                            text = _("Save"),
                            is_enter_default = true,
                            callback = function()
                                local zones = Settings:getGridZones()
                                local b = zones[zone_idx] and zones[zone_idx][block_idx]
                                if b then
                                    b.params.pattern = dlg:getInputText()
                                    save_zones(zones)
                                end
                                UIManager:close(dlg)
                            end,
                        },
                    }},
                }
                UIManager:show(dlg)
                dlg:onShowKeyboard()
            end,
        })
    elseif block.type == "sleep_stats" then
        table.insert(items, {
            text = _("Mode: use KOReader stock line"),
            radio = true,
            checked_func = function()
                return block.params.mode ~= "template"
            end,
            callback = function()
                block.params.mode = "stock"
                block.params.pattern = nil
                save_zones(Settings:getGridZones())
            end,
        })
        table.insert(items, {
            text = _("Mode: custom template"),
            radio = true,
            checked_func = function()
                return block.params.mode == "template"
            end,
            callback = function()
                local zones = Settings:getGridZones()
                local b = zones[zone_idx] and zones[zone_idx][block_idx]
                if b then
                    b.params.mode = "template"
                    save_zones(zones)
                end
            end,
        })
        table.insert(items, {
            text = _("Edit stats template…"),
            callback = function()
                local dlg
                dlg = InputDialog:new{
                    title = _("Stats template"),
                    input = block.params.pattern or "",
                    buttons = {{
                        {
                            text = _("Cancel"),
                            callback = function()
                                UIManager:close(dlg)
                            end,
                        },
                        {
                            text = _("Save"),
                            is_enter_default = true,
                            callback = function()
                                local zones = Settings:getGridZones()
                                local b = zones[zone_idx] and zones[zone_idx][block_idx]
                                if b then
                                    b.params.mode = "template"
                                    b.params.pattern = dlg:getInputText()
                                    save_zones(zones)
                                end
                                UIManager:close(dlg)
                            end,
                        },
                    }},
                }
                UIManager:show(dlg)
                dlg:onShowKeyboard()
            end,
        })
    elseif block.type == "clock_analog" then
        table.insert(items, {
            text = _("Analog dial diameter % (50–100)…"),
            callback = function()
                local dlg
                dlg = InputDialog:new{
                    title = _("Dial diameter"),
                    input = tostring(block.params.diameter_pct or 100),
                    buttons = {{
                        {
                            text = _("Cancel"),
                            callback = function()
                                UIManager:close(dlg)
                            end,
                        },
                        {
                            text = _("Save"),
                            is_enter_default = true,
                            callback = function()
                                local n = tonumber(dlg:getInputText())
                                if n then
                                    n = math.max(50, math.min(100, math.floor(n)))
                                    local zones = Settings:getGridZones()
                                    local b = zones[zone_idx] and zones[zone_idx][block_idx]
                                    if b then
                                        b.params.diameter_pct = n
                                        save_zones(zones)
                                    end
                                end
                                UIManager:close(dlg)
                            end,
                        },
                    }},
                }
                UIManager:show(dlg)
                dlg:onShowKeyboard()
            end,
        })
    elseif block.type == "clock" then
        table.insert(items, {
            text = _("Edit time format…"),
            callback = function()
                local dlg
                dlg = InputDialog:new{
                    title = _("strftime format"),
                    input = block.params.format or "%H:%M",
                    buttons = {{
                        {
                            text = _("Cancel"),
                            callback = function()
                                UIManager:close(dlg)
                            end,
                        },
                        {
                            text = _("Save"),
                            is_enter_default = true,
                            callback = function()
                                local zones = Settings:getGridZones()
                                local b = zones[zone_idx] and zones[zone_idx][block_idx]
                                if b then
                                    b.params.format = dlg:getInputText()
                                    save_zones(zones)
                                end
                                UIManager:close(dlg)
                            end,
                        },
                    }},
                }
                UIManager:show(dlg)
                dlg:onShowKeyboard()
            end,
        })
    elseif block.type == "highlight" then
        table.insert(items, {
            text = _("Highlight uses document annotations (see KOReader docs)."),
            callback = function()
                UIManager:show(InfoMessage:new{
                    text = _("Footer template uses %% codes from placeholder reference."),
                    timeout = 3,
                })
            end,
        })
    end

    table.insert(items, {
        text = _("Move block up"),
        callback = function()
            local zones = Settings:getGridZones()
            local stack = zones[zone_idx]
            if not stack or block_idx <= 1 then return end
            stack[block_idx], stack[block_idx - 1] = stack[block_idx - 1], stack[block_idx]
            save_zones(zones)
        end,
    })

    table.insert(items, {
        text = _("Move block down"),
        callback = function()
            local zones = Settings:getGridZones()
            local stack = zones[zone_idx]
            if not stack or block_idx >= #stack then return end
            stack[block_idx], stack[block_idx + 1] = stack[block_idx + 1], stack[block_idx]
            save_zones(zones)
        end,
    })

    table.insert(items, {
        text = _("Remove block"),
        callback = function()
            local zones = Settings:getGridZones()
            table.remove(zones[zone_idx], block_idx)
            save_zones(zones)
        end,
    })

    return items
end

function GridEditor.zoneMenu(zone_idx)
    local zones = Settings:getGridZones()
    local stack = zones[zone_idx] or {}
    local items = {}
    for i, block in ipairs(stack) do
        table.insert(items, {
            text = string.format("%d · %s", i, block.type),
            sub_item_table_func = function()
                return GridEditor.blockMenu(zone_idx, i)
            end,
        })
    end
    table.insert(items, {
        text = _("Add block…"),
        sub_item_table_func = function()
            return GridEditor.addBlockMenu(zone_idx)
        end,
    })
    return items
end

function GridEditor.gridZonesMenu()
    local items = {}
    local names = {
        _("Zone 1 — top left"),
        _("Zone 2 — top center"),
        _("Zone 3 — top right"),
        _("Zone 4 — middle left"),
        _("Zone 5 — center"),
        _("Zone 6 — middle right"),
        _("Zone 7 — bottom left"),
        _("Zone 8 — bottom center"),
        _("Zone 9 — bottom right"),
    }
    for z = 1, 9 do
        local zones = Settings:getGridZones()
        local n = #(zones[z] or {})
        table.insert(items, {
            text = string.format("%s (%d)", names[z], n),
            sub_item_table_func = function()
                return GridEditor.zoneMenu(z)
            end,
        })
    end
    return items
end

return GridEditor
