data:extend({
    {
        type = "bool-setting",
        name = "player_TTS",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "distance_limit_enabled",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "b"
    },
    {
        type = "double-setting",
        name = "distance_limit",
        setting_type = "runtime-per-user",
        minimum_value = 10.0,
        maximum_value = 250,
        default_value = 150,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "train_stop_voices",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "d"
    },
    {
        type = "double-setting",
        name = "distance_limit_trains",
        setting_type = "runtime-per-user",
        minimum_value = 10,
        maximum_value = 250,
        default_value = 150,
        order = "e"
    },
})
