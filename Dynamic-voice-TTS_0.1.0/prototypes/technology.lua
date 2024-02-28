data:extend({
    {
      type = "technology",
      name = "TTS-speaker-technology",
      icon_size = 512,
      icon = "__Dynamic-voice-TTS__/thumbnail.png",
      prerequisites = {"circuit-network"}, -- Specify prerequisite technologies
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "TTS-programmable-speaker-recipe"
        }
      },
      unit =
        {
            count = 50, -- Research cost
            ingredients =
                {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1}
                },
            time = 30
        },

      order = "c-a"
    }
  })
  