-- Generated Noctalia colors, migrated from noctalia-colors.conf.
local primary = "rgb(83d1ef)"
local surface = "rgb(101416)"
local secondary = "rgb(aecbd8)"
local errorColor = "rgb(ffb4ab)"

hl.config({
    general = {
        col = {
            active_border = primary,
            inactive_border = surface,
        },
    },
    group = {
        col = {
            border_active = secondary,
            border_inactive = surface,
            border_locked_active = errorColor,
            border_locked_inactive = surface,
        },
        groupbar = {
            col = {
                active = secondary,
                inactive = surface,
                locked_active = errorColor,
                locked_inactive = surface,
            },
        },
    },
})
