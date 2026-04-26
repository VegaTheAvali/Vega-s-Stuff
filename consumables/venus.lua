local function blind_payout_gain(self, level)
    return Vegasstuff.tiered_geomancy_gain(self.config.extra, level)
end

local function blind_payout_total(level)
    return Vegasstuff.total_tiered_geomancy_gain({ base_gain = 1, tier_levels = 4, tier_mode = "add" }, level)
end

local function current_blind_payout_bonus()
    return blind_payout_total(Vegasstuff.get_geomancy_level("venus"))
end

if not _G.vegasstuff_venus_round_eval_hooked then
    _G.vegasstuff_venus_round_eval_hooked = true
    local evaluate_round_ref = G.FUNCS.evaluate_round
    local unpack_fn = table.unpack or unpack
    function G.FUNCS.evaluate_round(...)
        local has_blind = G and G.GAME and G.GAME.blind and G.GAME.blind.dollars
        local won_blind = has_blind and to_big(G.GAME.chips) >= to_big(G.GAME.blind.chips)
        local venus_bonus = won_blind and current_blind_payout_bonus() or 0
        local original_blind_dollars = has_blind and G.GAME.blind.dollars or nil

        if has_blind and venus_bonus > 0 then
            G.GAME.blind.dollars = original_blind_dollars + venus_bonus
        end

        local results = { evaluate_round_ref(...) }

        if has_blind and original_blind_dollars ~= nil then
            G.GAME.blind.dollars = original_blind_dollars
        end

        return unpack_fn(results)
    end
end

SMODS.Consumable {
    key = 'venus',
    config = {
        extra = {
            max_level = 20,
            base_gain = 1,
            tier_levels = 4,
            tier_mode = "add",
            tracker_key = "venus",
            fallback_center_key = "c_vegasstuff_venus"
        }
    },
    set = 'geomancy',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    loc_txt = {
        name = '{C:vegasstuff_name_venus}Venus{}',
        text = {
            [1] = 'Earn {C:money}+$#1#{} extra from blind payout',
            [2] = '{C:inactive}(Level #2#/#4#, Total +$#3# blind payout){}'
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
        local next_gain = level >= extra.max_level and 0 or blind_payout_gain(self, next_level)
        return { vars = { next_gain, next_level, blind_payout_total(next_level), extra.max_level } }
    end,
    can_use = function(self)
        return Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local current_level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if current_level >= extra.max_level then
            return
        end

        local next_level = current_level + 1
        local gain = blind_payout_gain(self, next_level)
        local total = blind_payout_total(next_level)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)
        Vegasstuff.juice_and_status(used_card, "+$" .. tostring(gain) .. " blind payout (Total +$" .. tostring(total) .. ")", G.C.MONEY)
    end,
}