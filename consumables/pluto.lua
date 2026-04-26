local function total_xmult(level)
    return math.max(0, level) * 1.2
end

local function apply_xmult_total(target_level)
    return Vegasstuff.apply_permanent_to_deck("perma_x_mult", total_xmult(target_level) - 1, "max")
end

SMODS.Consumable {
    key = 'pluto',
    config = {
        extra = {
            max_level = 20,
            tracker_key = "pluto",
            fallback_center_key = "c_vegasstuff_pluto",
            gain = 1.2
        }
    },
    set = 'geomancy',
    pos = { x = 2, y = 1 },
    soul_pos = { x = 3, y = 1 },
    loc_txt = {
        name = '{C:vegasstuff_name_pluto}Pluto{}',
        text = {
            [1] = 'All cards gain {X:red,C:white}X#1#{} permanent Mult',
            [2] = '{C:inactive}(Level #2#/#3#, Total from Pluto: X#4#){}'
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
                Vegasstuff.format_number(total_xmult(level), 2)
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
        local affected = apply_xmult_total(next_level)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)

        if affected > 0 then
            Vegasstuff.juice_and_status(used_card, "X" .. Vegasstuff.format_number(total_xmult(next_level), 2), G.C.RED)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}