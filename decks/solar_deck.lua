local SOLAR_TAG_KEY = "tag_vegasstuff_astro"
local SOLAR_CHOICES_SMALL_BIG = 3
local SOLAR_CHOICES_BOSS = 5
local unpack_fn = table.unpack or unpack

local function solar_is_active()
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.vegasstuff_solar_deck
end

local function solar_choices_from_blind(blind_name)
    if blind_name == "Small" or blind_name == "Big" then
        return SOLAR_CHOICES_SMALL_BIG
    end
    return SOLAR_CHOICES_BOSS
end

local function solar_set_blind_reward_tags()
    if not (G and G.GAME and G.GAME.round_resets) then
        return
    end
    G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
    G.GAME.round_resets.blind_tags.Small = SOLAR_TAG_KEY
    G.GAME.round_resets.blind_tags.Big = SOLAR_TAG_KEY
    G.GAME.round_resets.blind_tags.Boss = SOLAR_TAG_KEY
end

if not rawget(_G, "vegasstuff_solar_hooks_installed") then
    _G.vegasstuff_solar_hooks_installed = true

    local add_round_eval_row_ref = add_round_eval_row
    function add_round_eval_row(config)
        if solar_is_active() and config and (config.name == "interest" or config.name == "interest_payload" or config.name == "hands") then
            return
        end
        return add_round_eval_row_ref(config)
    end

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        if not (G and G.GAME) or not solar_is_active() then
            return evaluate_round_ref(...)
        end

        local base_no_interest = G.GAME.modifiers and G.GAME.modifiers.no_interest
        local base_no_extra_hand_money = G.GAME.modifiers and G.GAME.modifiers.no_extra_hand_money
        local base_interest_amount = G.GAME.interest_amount
        local base_interest_cap = G.GAME.interest_cap
        local base_cry_payload = G.GAME.cry_payload

        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.no_interest = true
        G.GAME.modifiers.no_extra_hand_money = true
        G.GAME.interest_amount = 0
        G.GAME.interest_cap = 0
        G.GAME.cry_payload = nil

        local results = { evaluate_round_ref(...) }

        G.GAME.modifiers.no_interest = base_no_interest
        G.GAME.modifiers.no_extra_hand_money = base_no_extra_hand_money
        G.GAME.interest_amount = base_interest_amount
        G.GAME.interest_cap = base_interest_cap
        G.GAME.cry_payload = base_cry_payload

        return unpack_fn(results)
    end

    local reset_blinds_ref = reset_blinds
    function reset_blinds(...)
        local result = { reset_blinds_ref(...) }
        if solar_is_active() then
            solar_set_blind_reward_tags()
        end
        return unpack_fn(result)
    end

    local cash_out_ref = G.FUNCS.cash_out
    function G.FUNCS.cash_out(e, ...)
        if not solar_is_active() then
            return cash_out_ref(e, ...)
        end

        stop_use()

        local cleared_blind = (G and G.GAME and G.GAME.blind_on_deck) or "Small"
        G.GAME.vegasstuff_solar_pending_choices = solar_choices_from_blind(cleared_blind)

        if G.round_eval then
            if e and e.config then
                e.config.button = nil
            end
            G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
            G.round_eval.alignment.offset.x = 0
            G.deck:shuffle("cashout" .. G.GAME.round_resets.ante)
            G.deck:hard_set_T()
            delay(0.3)
            G.E_MANAGER:add_event(Event({
                trigger = "immediate",
                func = function()
                    if G.round_eval then
                        G.round_eval:remove()
                        G.round_eval = nil
                    end
                    G.GAME.current_round.jokers_purchased = 0
                    G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
                    G.GAME.current_round.hands_left = math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands)
                    G.STATE = G.STATES.BLIND_SELECT
                    G.STATE_COMPLETE = false
                    G.GAME.shop_free = nil
                    G.GAME.shop_d6ed = nil
                    G.GAME.previous_round.dollars = G.GAME.dollars
                    return true
                end
            }))
        end

        ease_chips(to_big(0))
        if G.GAME.round_resets.blind_states.Boss == "Defeated" then
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
        end
        reset_blinds()
        solar_set_blind_reward_tags()
        add_tag(Tag(SOLAR_TAG_KEY))
        delay(0.6)
    end
end

SMODS.Back({
    key = "solar_deck",
    pos = { x = 2, y = 2 },
    config = {},
    loc_txt = {
        name = "Solar Deck",
        text = {
            [1] = "Blind rewards are replaced with {C:attention}Astro Tags{}",
            [2] = "Gain {C:money}$0{} after each blind and skip the {C:attention}Shop{}",
            [3] = "Each Astro Tag redeems into a free {C:purple}Astro Pack{}."
        }
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = "GeomancyCards",
    apply = function(self, back)
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers.vegasstuff_solar_deck = true
        G.GAME.modifiers.no_interest = true
        G.GAME.modifiers.no_extra_hand_money = true
        G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
        G.GAME.modifiers.no_blind_reward.Small = true
        G.GAME.modifiers.no_blind_reward.Big = true
        G.GAME.modifiers.no_blind_reward.Boss = true
        solar_set_blind_reward_tags()
    end
})
