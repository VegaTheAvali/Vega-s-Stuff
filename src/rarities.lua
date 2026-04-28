SMODS.Rarity {
    key = "cry_exotic",
    pools = {
        ["Joker"] = true
    },
    default_weight = 0.1,
    disable_if_empty = true,
    badge_colour = HEX('216563'),
    
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
    disable_if_empty = true,
    badge_colour = HEX('6A7A8B'),
    
    get_weight = function(self, weight, object_type)
        return weight
    end,
}