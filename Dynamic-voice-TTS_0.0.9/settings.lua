data:extend({
    {
        type = "bool-setting",
        name = "TTS_MOD_player_TTS",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "TTS_MOD_distance_limit_enabled",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "b"
    },
    {
        type = "double-setting",
        name = "TTS_MOD_distance_limit",
        setting_type = "runtime-per-user",
        minimum_value = 10.0,
        maximum_value = 250,
        default_value = 150,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "TTS_MOD_train_stop_voices",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "d1"
    },
    {
        type = "string-setting",
        name = "TTS_MOD_train_announcement_text",
        setting_type = "runtime-per-user",
        default_value = ".. Next stop .......",
        order = "d2"
    },
    {
        type = "double-setting",
        name = "TTS_MOD_distance_limit_trains",
        setting_type = "runtime-per-user",
        minimum_value = 10,
        maximum_value = 250,
        default_value = 150,
        order = "e"
    },
    {
        type = "string-setting",
        name = "TTS_MOD_voice_model",
        setting_type = "runtime-per-user",
        default_value = "en-GB-RyanNeural",
        order = "f"
    },
    {
        type = "string-setting",
        name = "TTS_MOD_voice_rate",
        setting_type = "runtime-per-user",
        default_value = "+0%",
        order = "g"
    },
    {
        type = "string-setting",
        name = "TTS_MOD_check_delay",
        setting_type = "runtime-per-user",
        default_value = "50",
        order = "h"
    },
    {
        type = "bool-setting",
        name = "TTS_MOD_startup_message",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "i"
    }
})
