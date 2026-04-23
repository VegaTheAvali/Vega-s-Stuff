SMODS.Rarity {
    key = "cry_exotic",
    pools = {
        ["Joker"] = true
    },
    default_weight = 0.1,
    badge_colour = HEX('216563'),
    loc_txt = {
        name = "Exotic"
    },
    get_weight = function(self, weight, object_type)
        return weight
    end,
}

SMODS.Rarity {
    key = "jen_transcendent",
    pools = {
        ["Joker"] = true
    },
    default_weight = 0.1,
    badge_colour = HEX('6A7A8B'),
    loc_txt = {
        name = "Transcendent"
    },
    get_weight = function(self, weight, object_type)
        return weight
    end,
}