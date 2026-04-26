SMODS.Consumable {
    key = "terra",
    config = {
        extra = {
            max_level = 5,
            tracker_key = "terra",
            fallback_center_key = "c_vegasstuff_terra"
        }
    },
    set = "geomancy",
    pos = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
    loc_txt = {
        name = '{C:vegasstuff_name_terra}Terra{}',
        text = {
            [1] = "Permanently gain {C:attention}+1{} hand size",
            [2] = "{C:inactive}(Level #1#/#2#, Total +#1# hand size){}"
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = "GeomancyCards",
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self)
    end,
    loc_vars = function(self)
        local level = Vegasstuff.get_geomancy_level_from_extra(self.config.extra)
        return { vars = { level, self.config.extra.max_level } }
    end,
    can_use = function(self)
        return G and G.hand and Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if level >= extra.max_level then
            return
        end

        G.hand:change_size(1)
        Vegasstuff.set_geomancy_level_from_extra(extra, level + 1)
        Vegasstuff.juice_and_status(used_card, "+1 Hand Size", G.C.IMPORTANT or G.C.YELLOW)
    end,
}