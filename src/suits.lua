do
local SUITS = {
    {
        key = "Swords",
        card_key = "SWORDS",
        pos = { x = 0, y = 0 },
        ui_pos = { x = 0, y = 0 },
        lc_colour = HEX("ff2f5f"),
        hc_colour = HEX("ff5a78")
    },
    {
        key = "Cups",
        card_key = "CUPS",
        pos = { x = 0, y = 1 },
        ui_pos = { x = 1, y = 0 },
        lc_colour = HEX("00a6d9"),
        hc_colour = HEX("33c4ff")
    },
    {
        key = "Pentacles",
        card_key = "PENTACLES",
        pos = { x = 0, y = 2 },
        ui_pos = { x = 2, y = 0 },
        lc_colour = HEX("ff8a26"),
        hc_colour = HEX("ffb13b")
    },
    {
        key = "Wands",
        card_key = "WANDS",
        pos = { x = 0, y = 3 },
        ui_pos = { x = 3, y = 0 },
        lc_colour = HEX("6d4a8f"),
        hc_colour = HEX("9d72d9")
    }
}

for _, suit in ipairs(SUITS) do
    SMODS.Suit {
        key = suit.key,
        card_key = suit.card_key,
        hidden = true,

        lc_atlas = "SuitsLC",
        hc_atlas = "SuitsHC",
        lc_ui_atlas = "SuitsUILC",
        hc_ui_atlas = "SuitsUIHC",

        pos = suit.pos,
        ui_pos = suit.ui_pos,
        lc_colour = suit.lc_colour,
        hc_colour = suit.hc_colour,

        in_pool = function(self, args)
            return not (args and args.initial_deck)
        end
    }
end
end
