local function hand_size_gain()
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(1), 1)
end

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
            [1] = "{C:attention}Permanently{} gain {C:attention}+#1#{} {C:attention}hand size{}",
            [2] = "{C:inactive}(Level #2#/#3#, Total +#4# hand size){}"
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
        return { vars = { hand_size_gain(), level, self.config.extra.max_level, level * hand_size_gain() } }
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

        local gain = hand_size_gain()
        G.hand:change_size(gain)
        Vegasstuff.set_geomancy_level_from_extra(extra, level + 1)
        Vegasstuff.juice_and_status(used_card, "+" .. tostring(gain) .. " Hand Size", G.C.IMPORTANT or G.C.YELLOW)
    end,
}
