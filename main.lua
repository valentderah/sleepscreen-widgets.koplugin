local WidgetContainer = require("ui/widget/container/widgetcontainer")

local AwesomeSleepscreen = WidgetContainer:extend{
    name = "awesome_sleepscreen",
    is_doc_only = false,
}

function AwesomeSleepscreen:onResume()
    require("menu.lock_overlay").onResume(self)
end

function AwesomeSleepscreen:init()
    require("l10n").load()
    local MenuHook = require("menu.menu_hook")
    local Banner = require("banner")
    MenuHook.install(self)
    Banner.install()
end

return AwesomeSleepscreen
