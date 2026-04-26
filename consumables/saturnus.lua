local function current_interest_bonus()
    return math.min(4, Vegasstuff.get_geomancy_level("saturnus"))
end

if not _G.vegasstuff_saturnus_round_eval_hooked then
    _G.vegasstuff_saturnus_round_eval_hooked = true
    local evaluate_round_ref = G.FUNCS.evaluate_round
    local unpack_fn = table.unpack or unpack
    function G.FUNCS.evaluate_round(...)
        local has_game = G and G.GAME
        local base_interest = has_game and (tonumber(G.GAME.interest_amount) or 0) or 0
        local base_interest_cap = has_game and (tonumber(G.GAME.interest_cap) or 0) or 0
        local saturnus_bonus = has_game and current_interest_bonus() or 0

        if has_game and saturnus_bonus > 0 then
            G.GAME.interest_amount = base_interest + saturnus_bonus
            G.GAME.interest_cap = 1e300
        end

        local results = { evaluate_round_ref(...) }

        if has_game then
            G.GAME.interest_amount = base_interest
            G.GAME.interest_cap = base_interest_cap
        end

        return unpack_fn(results)
    end
end

SMODS.Consumable {
    key = 'saturnus',
    config = {
        extra = {
            max_level = 4,
            tracker_key = "saturnus",
            fallback_center_key = "c_vegasstuff_saturnus"
        }
    },
    set = 'geomancy',
    pos = { x = 6, y = 1 },
    soul_pos = { x = 7, y = 1 },
    loc_txt = {
        name = '{C:vegasstuff_name_saturnus}Saturnus{}',
        text = {
            [1] = 'Increase interest amount by {C:money}+#1#{}',
            [2] = 'Interest cap is {C:attention}removed{} during payout',
            [3] = '{C:inactive}(Level #2#/#4#, Total +#3# interest amount){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'GeomancyCards',
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self, { solar_disabled = true })
    end,
    loc_vars = function(self)
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        local next_level = math.min(level + 1, extra.max_level)
        return { vars = { level >= extra.max_level and 0 or 1, next_level, next_level, extra.max_level } }
    end,
    can_use = function(self)
        return Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if level >= extra.max_level then
            return
        end

        local next_level = level + 1
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)
        Vegasstuff.juice_and_status(used_card, "+Interest 1 (Total +" .. tostring(next_level) .. ")", G.C.MONEY)
    end,
}