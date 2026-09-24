SMODS.Sticker {
    key = "retro_seed",

    atlas = "Stickers",
    pos = { x = 1, y = 0 },

    badge_colour = HEX("306230"),
    default_compat = true,

    calculate = function(self, card, context)
        if context.fix_probability
            and context.trigger_obj == card then

            return {
                numerator = context.denominator
            }
        end
    end,
}