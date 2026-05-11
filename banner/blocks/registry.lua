local logger = require("logger")

local Registry = { _types = {} }

function Registry.register(type_id, builder)
    Registry._types[type_id] = builder
end

function Registry.build(block, ctx)
    local id = block.type
    local fn = Registry._types[id]
    if not fn then
        logger.warn("awesome_sleepscreen", "unknown block type: " .. tostring(id))
        return nil
    end
    return fn(block.params or {}, ctx)
end

function Registry.ensure_registered()
    if Registry._registered then return end
    Registry._registered = true
    -- Inline block registration (must not use `:init(Registry)` on a helper module:
    -- colon syntax passes `self` as the first arg and would break `Registry.register`.)
    require("banner.blocks.template").register(Registry)
    require("banner.blocks.sleep_stats").register(Registry)
    require("banner.blocks.highlight").register(Registry)
    require("banner.blocks.clock").register(Registry)
    require("banner.blocks.analog_clock").register(Registry)
end

return Registry
