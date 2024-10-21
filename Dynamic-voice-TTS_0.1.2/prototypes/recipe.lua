data:extend({
-- Recipe to craft the speaker
    {
        type = "recipe",
        name = "TTS-programmable-speaker-recipe",
        enabled = false,
        ingredients =
        {
            {type="item", name="programmable-speaker", amount=1},
            {type="item", name="copper-cable", amount=1},
            {type="item", name="electronic-circuit", amount=1}
        },
        results = {
            {type="item", name="TTS-programmable-speaker-item", amount=1}
        }
    }
})