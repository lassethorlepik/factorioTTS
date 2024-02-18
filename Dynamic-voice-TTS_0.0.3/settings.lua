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
        type = "int-setting",
        name = "distance_limit",
        setting_type = "runtime-per-user",
        minimum_value = 10,
        maximum_value = 1000,
        default_value = 250,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "train_stop_voices",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "d"
    }
})
