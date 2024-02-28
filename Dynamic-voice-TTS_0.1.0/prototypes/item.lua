data:extend({
    {
        type = "programmable-speaker",
        name = "TTS-programmable-speaker",
        icon = "__base__/graphics/icons/programmable-speaker.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.1, result = "TTS-programmable-speaker-item"},
        maximum_polyphony = 25,
        instruments = {},
        max_health = 150,
        corpse = "programmable-speaker-remnants",
        dying_explosion = "programmable-speaker-explosion",

        collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        drawing_box = {{-0.5, -2.5}, {0.5, 0.3}},
        vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.5 },
        close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.5 },


        -- Sprite definitions for the entity
        sprite =
        {
          layers =
          {
            {
              filename = "__base__/graphics/entity/programmable-speaker/programmable-speaker.png",
              priority = "extra-high",
              width = 30,
              height = 89,
              shift = util.by_pixel(-2, -39.5),
              hr_version =
              {
                filename = "__base__/graphics/entity/programmable-speaker/hr-programmable-speaker.png",
                priority = "extra-high",
                width = 59,
                height = 178,
                shift = util.by_pixel(-2.25, -39.5),
                scale = 0.5
              }
            },
            {
              filename = "__base__/graphics/entity/programmable-speaker/programmable-speaker-shadow.png",
              priority = "extra-high",
              width = 119,
              height = 25,
              shift = util.by_pixel(52.5, -2.5),
              draw_as_shadow = true,
              hr_version =
              {
                filename = "__base__/graphics/entity/programmable-speaker/hr-programmable-speaker-shadow.png",
                priority = "extra-high",
                width = 237,
                height = 50,
                shift = util.by_pixel(52.75, -3),
                draw_as_shadow = true,
                scale = 0.5
              }
            }
          }
        },

        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = 0,
        },
        energy_usage_per_tick = "4kW",

        -- Circuit network connections
        circuit_wire_connection_point = circuit_connector_definitions["programmable-speaker"].points,
        circuit_connector_sprites = circuit_connector_definitions["programmable-speaker"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        water_reflection = {
            pictures = {
                    filename = "__base__/graphics/entity/programmable-speaker/programmable-speaker-reflection.png",
                    priority = "extra-high",
                    width = 12,
                    height = 24,
                    shift = util.by_pixel(0, 45),
                    variation_count = 1,
                    scale = 5
            },
            rotate = false,
            orientation_to_variation = false
        }
    },
    {
        type = "item",
        name = "TTS-programmable-speaker-item",
        icon = "__base__/graphics/icons/programmable-speaker.png",
        icon_size = 64,
        place_result = "TTS-programmable-speaker",
        flags = {},
        subgroup = "circuit-network",
        order = "programmable-speaker2",
        stack_size = 50,
    },
    -- Recipe to craft the speaker
    {
        type = "recipe",
        name = "TTS-programmable-speaker-recipe",
        enabled = false,
        ingredients =
        {
            {"programmable-speaker", 1},
            {"copper-cable", 1},
            {"electronic-circuit", 1}
        },
        result = "TTS-programmable-speaker-item"
    }
})
