SMODS.ConsumableType {
    key = 'zodiac',
    primary_colour = HEX('a600f9'),
    secondary_colour = HEX('a600f9'),
    collection_rows = { 6, 6 },
    shop_rate = 1,
    cards = {
        ['c_vegasstuff_aquarius'] = true,
        ['c_vegasstuff_aries'] = true,
        ['c_vegasstuff_cancer'] = true,
        ['c_vegasstuff_capricorn'] = true,
        ['c_vegasstuff_gemini'] = true,
        ['c_vegasstuff_leo'] = true,
        ['c_vegasstuff_libra'] = true,
        ['c_vegasstuff_pisces'] = true,
        ['c_vegasstuff_sagittarius'] = true,
        ['c_vegasstuff_scorpio'] = true,
        ['c_vegasstuff_taurus'] = true,
        ['c_vegasstuff_virgo'] = true,
    },
    
}

SMODS.ConsumableType {
    key = 'geomancy',
    primary_colour = HEX('f8585a'),
    secondary_colour = HEX('ff9352'),
    collection_rows = { 6, 6 },
    shop_rate = 1,
    cards = {
        ['c_vegasstuff_sol'] = true,
        ['c_vegasstuff_terra'] = true,
        ['c_vegasstuff_mars'] = true,
        ['c_vegasstuff_luna'] = true,
        ['c_vegasstuff_neptunus'] = true,
        ['c_vegasstuff_venus'] = true,
        ['c_vegasstuff_pluto'] = true,
        ['c_vegasstuff_mercurius'] = true,
        ['c_vegasstuff_saturnus'] = true,
        ['c_vegasstuff_uranus'] = true,
        ['c_vegasstuff_jupiter'] = true,
    },
    
}

do
local ASC_POWER_GAIN = 1.25
local ASCENDED_COLOUR = { 14 / 255, 1, 0, 1 }

local function is_cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods["Cryptid"]
    return cryptid_mod and cryptid_mod.can_load and Cryptid and Cryptid.calculate_ascension_power
end

local function asc_power_gain()
    return Vegasstuff.scaled_geomancy_value(ASC_POWER_GAIN)
end

SMODS.Consumable {
    key = 'sol',
    config = {
        extra = {
            max_level = 20,
            tracker_key = "sol",
            fallback_center_key = "c_vegasstuff_sol"
        }
    },
    set = 'geomancy',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    
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
        return {
            vars = {
                Vegasstuff.format_number(asc_power_gain(), 2),
                Vegasstuff.get_geomancy_level_from_extra(self.config.extra),
                self.config.extra.max_level,
                colours = { ASCENDED_COLOUR }
            }
        }
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

        Vegasstuff.set_geomancy_level_from_extra(extra, level + 1)
        if is_cryptid_active() then
            G.GAME.bonus_asc_power = (G.GAME.bonus_asc_power or 0) + asc_power_gain()
        else
            G.GAME.vegas_bonus_asc_power = (G.GAME.vegas_bonus_asc_power or 0) + asc_power_gain()
        end
        Vegasstuff.juice_and_status(used_card, "+Ascension", G.C.GOLD)
    end
}
end

do
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
end

do
local function leveled_deck_stat_gain(self, level)
    return Vegasstuff.tiered_geomancy_gain(self.config.extra, level)
end

local function total_deck_stat_gain(self, level)
    return Vegasstuff.total_tiered_geomancy_gain(self.config.extra, level)
end

SMODS.Consumable {
    key = 'mars',
    config = {
        extra = {
            max_level = 20,
            base_gain = 2,
            tier_levels = 4,
            tracker_key = "mars",
            fallback_center_key = "c_vegasstuff_mars",
            stat_key = "perma_mult"
        }
    },
    set = 'geomancy',
    pos = { x = 4, y = 0 },
    soul_pos = { x = 5, y = 0 },
    
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
            Vegasstuff.juice_and_status(used_card, "+" .. tostring(gain) .. " Mult", G.C.RED)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}
end

do
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
end

do
local function xchips_gain(extra)
    return Vegasstuff.scaled_geomancy_value((extra and extra.gain) or 1.2)
end

local function total_xchips(level, extra)
    return math.max(0, level) * xchips_gain(extra)
end

local function apply_xchips_total(target_level, extra)
    return Vegasstuff.apply_permanent_to_deck("perma_x_chips", total_xchips(target_level, extra) - 1, "max")
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
                Vegasstuff.format_number(xchips_gain(extra), 2),
                level,
                extra.max_level,
                Vegasstuff.format_number(total_xchips(level, extra), 2)
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
        local affected = apply_xchips_total(next_level, extra)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)

        if affected > 0 then
            Vegasstuff.juice_and_status(used_card, "X" .. Vegasstuff.format_number(total_xchips(next_level, extra), 2), G.C.BLUE)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}
end

do
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
        return { vars = { next_gain, level, blind_payout_total(level), extra.max_level } }
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
end

do
local function xmult_gain(extra)
    return Vegasstuff.scaled_geomancy_value((extra and extra.gain) or 1.2)
end

local function total_xmult(level, extra)
    return math.max(0, level) * xmult_gain(extra)
end

local function apply_xmult_total(target_level, extra)
    return Vegasstuff.apply_permanent_to_deck("perma_x_mult", total_xmult(target_level, extra) - 1, "max")
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
                Vegasstuff.format_number(xmult_gain(extra), 2),
                level,
                extra.max_level,
                Vegasstuff.format_number(total_xmult(level, extra), 2)
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
        local affected = apply_xmult_total(next_level, extra)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)

        if affected > 0 then
            Vegasstuff.juice_and_status(used_card, "X" .. Vegasstuff.format_number(total_xmult(next_level, extra), 2), G.C.RED)
        elseif used_card then
            used_card:juice_up(0.3, 0.5)
        end
    end
}
end

do
local BASE_TARGET_BUYS = 10
local MIN_TARGET_BUYS = 1

local function level()
    return Vegasstuff.get_geomancy_level("mercurius")
end

local function is_active()
    return level() > 0
end

local function level_value()
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(level()), 0)
end

local function required_buys()
    return math.max(MIN_TARGET_BUYS, BASE_TARGET_BUYS - level_value())
end

local function get_counter()
    if not (G and G.GAME) then
        return 0
    end
    local current = math.min(required_buys(), Vegasstuff.safe_int(G.GAME.vegasstuff_mercurius_buy_counter, 0))
    G.GAME.vegasstuff_mercurius_buy_counter = current
    return current
end

local function set_counter(value)
    if G and G.GAME then
        G.GAME.vegasstuff_mercurius_buy_counter = math.min(required_buys(), Vegasstuff.safe_int(value, 0))
    end
end

local function process_consumable_purchase(card)
    if not (card and card.ability and card.ability.consumeable and is_active()) then
        return
    end

    local required = required_buys()
    local counter = get_counter()
    if counter >= required then
        card:set_edition({ negative = true }, true, true)
        set_counter(0)
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Negative!",
            colour = G.C.DARK_EDITION or G.C.PURPLE,
        })
    else
        set_counter(counter + 1)
    end
end

Vegasstuff.register_shop_purchase_callback("mercurius", process_consumable_purchase)

SMODS.Consumable {
    key = "mercurius",
    config = {
        extra = {
            max_level = 9,
            tracker_key = "mercurius",
            fallback_center_key = "c_vegasstuff_mercurius"
        }
    },
    set = "geomancy",
    pos = { x = 4, y = 1 },
    soul_pos = { x = 5, y = 1 },
    
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = "GeomancyCards",
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self, { solar_disabled = true })
    end,
    loc_vars = function(self)
        return { vars = { required_buys(), get_counter(), level(), self.config.extra.max_level } }
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

        Vegasstuff.set_geomancy_level_from_extra(extra, current_level + 1)
        set_counter(0)
        Vegasstuff.juice_and_status(used_card, "Need " .. tostring(required_buys()) .. " consumables", G.C.DARK_EDITION or G.C.PURPLE)
    end,
}
end

do
local function interest_bonus_for_level(level)
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(math.min(4, Vegasstuff.safe_int(level, 0))), 0)
end

local function current_interest_bonus()
    return interest_bonus_for_level(Vegasstuff.get_geomancy_level("saturnus"))
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
        local current_total = interest_bonus_for_level(level)
        local next_total = level >= extra.max_level and current_total or interest_bonus_for_level(level + 1)
        return { vars = { next_total - current_total, level, current_total, extra.max_level } }
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
        Vegasstuff.juice_and_status(used_card, "+Interest " .. tostring(interest_bonus_for_level(next_level) - interest_bonus_for_level(level)) .. " (Total +" .. tostring(interest_bonus_for_level(next_level)) .. ")", G.C.MONEY)
    end,
}
end

do
local BASE_TARGET_BUYS = 5
local MIN_TARGET_BUYS = 1

local function level()
    return Vegasstuff.get_geomancy_level("uranus")
end

local function is_active()
    return level() > 0
end

local function level_value()
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(level()), 0)
end

local function required_buys()
    return math.max(MIN_TARGET_BUYS, BASE_TARGET_BUYS - level_value())
end

local function get_counter()
    if not (G and G.GAME) then
        return 0
    end
    local current = math.min(required_buys(), Vegasstuff.safe_int(G.GAME.vegasstuff_uranus_buy_counter, 0))
    G.GAME.vegasstuff_uranus_buy_counter = current
    return current
end

local function set_counter(value)
    if G and G.GAME then
        G.GAME.vegasstuff_uranus_buy_counter = math.min(required_buys(), Vegasstuff.safe_int(value, 0))
    end
end

local function process_joker_purchase(card)
    if not (card and card.ability and card.ability.set == "Joker" and is_active()) then
        return
    end

    local required = required_buys()
    local counter = get_counter()
    if counter >= required then
        card:set_edition({ negative = true }, true, true)
        set_counter(0)
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Negative!",
            colour = G.C.DARK_EDITION or G.C.PURPLE,
        })
    else
        set_counter(counter + 1)
    end
end

Vegasstuff.register_shop_purchase_callback("uranus", process_joker_purchase)

SMODS.Consumable {
    key = "uranus",
    config = {
        extra = {
            max_level = 4,
            tracker_key = "uranus",
            fallback_center_key = "c_vegasstuff_uranus"
        }
    },
    set = "geomancy",
    pos = { x = 8, y = 1 },
    soul_pos = { x = 9, y = 1 },
    
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = "GeomancyCards",
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self, { solar_disabled = true })
    end,
    loc_vars = function(self)
        return { vars = { required_buys(), get_counter(), level(), self.config.extra.max_level } }
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

        Vegasstuff.set_geomancy_level_from_extra(extra, current_level + 1)
        set_counter(0)
        Vegasstuff.juice_and_status(used_card, "Need " .. tostring(required_buys()) .. " Jokers", G.C.DARK_EDITION or G.C.PURPLE)
    end,
}
end

do
local function max_level()
    return 5
end

local function consumable_slots_for_level(target_level)
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(target_level or 0), 0)
end

local function pack_selections_for_level(target_level)
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(target_level or 0), 0)
end

local function consumable_slot_gain(current_level, next_level)
    return math.max(0, consumable_slots_for_level(next_level) - consumable_slots_for_level(current_level))
end

local function pack_selection_gain(current_level, next_level)
    return math.max(0, pack_selections_for_level(next_level) - pack_selections_for_level(current_level))
end

local function apply_consumable_slot_gain(amount)
    if amount > 0 and G and G.consumeables and G.consumeables.config then
        G.consumeables.config.card_limit = (G.consumeables.config.card_limit or 0) + amount
    end
end

local function apply_pack_selection_gain(amount)
    if amount > 0 and G and G.GAME then
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + amount
    end
end

local function jupiter_status(selection_gain, slot_gain)
    local selection_label = selection_gain == 1 and " Selection" or " Selections"
    local slot_label = slot_gain == 1 and " Slot" or " Slots"
    return "+" .. tostring(selection_gain) .. selection_label .. ", +" .. tostring(slot_gain) .. slot_label
end

SMODS.Consumable {
    key = "jupiter",
    config = {
        extra = {
            max_level = max_level(),
            tracker_key = "jupiter",
            fallback_center_key = "c_vegasstuff_jupiter"
        }
    },
    set = "geomancy",
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    
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
        local next_level = math.min(level + 1, self.config.extra.max_level)
        local selection_gain = level >= self.config.extra.max_level and 0 or pack_selection_gain(level, next_level)
        local slot_gain = level >= self.config.extra.max_level and 0 or consumable_slot_gain(level, next_level)
        return {
            vars = {
                selection_gain,
                slot_gain,
                level,
                self.config.extra.max_level,
                pack_selections_for_level(level),
                consumable_slots_for_level(level)
            }
        }
    end,
    can_use = function(self)
        return G and G.consumeables and G.consumeables.config and Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local current_level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if current_level >= extra.max_level then
            return
        end

        local next_level = current_level + 1
        local selection_gain = pack_selection_gain(current_level, next_level)
        local slot_gain = consumable_slot_gain(current_level, next_level)
        apply_pack_selection_gain(selection_gain)
        apply_consumable_slot_gain(slot_gain)
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)
        Vegasstuff.juice_and_status(used_card, jupiter_status(selection_gain, slot_gain), (G.C.SECONDARY_SET and G.C.SECONDARY_SET.Tarot) or G.C.PURPLE)
    end,
}
end
