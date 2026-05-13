local WidgetContainer = require("ui/widget/container/widgetcontainer")

local SleepscreenWidgets = WidgetContainer:extend{
    name = "sleepscreen_widgets",
    is_doc_only = false,
}

function SleepscreenWidgets:init()
    require("l10n").load()
    local MenuHook = require("menu.menu_hook")
    local Banner = require("banner")
    MenuHook.install(self)
    Banner.install()
end

return SleepscreenWidgets
