SMODS.Consumable {
    key = "croptid",
    set = "geomancy",
    pos = { x = 6, y = 0 },
    loc_txt = {
        name = "Croptid",
        text = {
            "Gain {C:money}$2{}"
        }
    },
    cost = 0,
    unlocked = true,
    discovered = true,
    hidden = false,
    no_collection = true,
    atlas = "lmfao",
    in_pool = function(self, args)
        return false
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        ease_dollars(2)
    end,
}
