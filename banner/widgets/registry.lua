local logger = require("logger")

local Registry = { _types = {}, _meta = {} }

function Registry.register(type_id, builder, meta)
    Registry._types[type_id] = builder
    meta = meta or {}
    local span = tonumber(meta.default_col_span)
    if span ~= 2 and span ~= 3 then
        span = 1
    end
    Registry._meta[type_id] = { default_col_span = span }
end

function Registry.default_col_span(type_id)
    local m = Registry._meta[type_id]
    return (m and m.default_col_span) or 1
end

function Registry.build(block, ctx)
    local id = block.type
    local fn = Registry._types[id]
    if not fn then
        logger.warn("awesome_sleepscreen", "unknown widget type: " .. tostring(id))
        return nil
    end
    return fn(block.params or {}, ctx)
end

function Registry.ensure_registered()
    if Registry._registered then return end
    Registry._registered = true
    Registry._meta = {}
    require("banner.widgets.template").register(Registry)
    require("banner.widgets.sleep_stats").register(Registry)
    require("banner.widgets.highlight").register(Registry)
    require("banner.widgets.clock").register(Registry)
    require("banner.widgets.analog_clock").register(Registry)
    require("banner.widgets.header_datetime").register(Registry)
    require("banner.widgets.battery_status").register(Registry)
    require("banner.widgets.reading_now").register(Registry)
    require("banner.widgets.calendar_tile").register(Registry)
    require("banner.widgets.today_reading").register(Registry)
end

return Registry
