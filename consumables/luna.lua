local function leveled_deck_stat_gain(self, level)
    return Vegasstuff.tiered_geomancy_gain(self.config.extra, level)
end

local function total_deck_stat_gain(self, level)
    return Vegasstuff.total_tiered_geomancy_gain(self.config.extra, level)
end

SMODS.Consumable {
    key = 'luna',
    config = {
        extra = {
            max_level = 20,
            base_gain = 20,
            tier_levels = 4,
            tracker_key = "luna",
            fallback_center_key = "c_vegasstuff_luna",
            stat_key = "perma_bonus"
        }
    },
    set = 'geomancy',
    pos = { x = 6, y = 0 },
    soul_pos = { x = 7, y = 0 },
    loc_txt = {
        name = '{C:vegasstuff_name_luna}Luna{}',
        text = {
            [1] = 'All cards gain {C:blue}+#1#{} permanent Chips',
            [2] = '{C:inactive}(Level #2#/#4#, Total +#3# Chips){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'GeomancyCards',
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self)
    end,
    loc_vars = function(self)
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        local next_level = math.min(level + 1, extra.max_level)
        local next_gain = level >= extra.max_level and 0 or leveled_deck_stat_gain(self, next_level)
        return { vars = { next_gain, level, total_deck_stat_gain(self, level), extra.max_level } }
    end,
    can_use = function(self)
        return G and G.playing_cards and #G.playing_cards > 0 and Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local current_level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if current_level >= extra.max_level then
            return
        end

        local next_level = current_level + 1
        local gain = leveled_deck_stat_gain(self, next_level)
        local affected = Vegasstuff.apply_permanent_to_deck(extra.stat_key, gain)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)

        if affected > 0 then
            Vegasstuff.juice_and_status(used_card, "+" .. tostring(gain) .. " Chips", G.C.BLUE)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}
