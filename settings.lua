local prefix = "equipment_hotkeys_"
data:extend({
    {
        type = "bool-setting",
        name = prefix .. "auto_disable",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "a"
    },
})
