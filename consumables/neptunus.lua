local function total_xchips(level)
    return math.max(0, level) * 1.2
end

local function apply_xchips_total(target_level)
    return Vegasstuff.apply_permanent_to_deck("perma_x_chips", total_xchips(target_level) - 1, "max")
end

SMODS.Consumable {
    key = 'neptunus',
    config = {
        extra = {
            max_level = 20,
            tracker_key = "neptunus",
            fallback_center_key = "c_vegasstuff_neptunus",
            gain = 1.2
        }
    },
    set = 'geomancy',
    pos = { x = 8, y = 0 },
    soul_pos = { x = 9, y = 0 },
    loc_txt = {
        name = '{C:vegasstuff_name_neptunus}Neptunus{}',
        text = {
            [1] = 'All cards gain {X:chips,C:white}X#1#{} permanent Chips',
            [2] = '{C:inactive}(Level #2#/#3#, Total from Neptunus: X#4#){}'
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
        return {
            vars = {
                Vegasstuff.format_number(extra.gain, 2),
                level,
                extra.max_level,
                Vegasstuff.format_number(total_xchips(level), 2)
            }
        }
    end,
    can_use = function(self)
        return G and G.playing_cards and #G.playing_cards > 0 and Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if level >= extra.max_level then
            return
        end

        local next_level = level + 1
        local affected = apply_xchips_total(next_level)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)

        if affected > 0 then
            Vegasstuff.juice_and_status(used_card, "X" .. Vegasstuff.format_number(total_xchips(next_level), 2), G.C.BLUE)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}