local SOLAR_TAG_KEY = "tag_vegasstuff_astro"
local SOLAR_CHOICES_SMALL_BIG = 3
local SOLAR_CHOICES_BOSS = 5
local SOLAR_RING_DRAW_SCALE = 0.18
local unpack_fn = table.unpack or unpack

local function solar_is_active()
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.vegasstuff_solar_deck
end

local function solar_center_from_back(back)
    return back and back.effect and back.effect.center
end

local function solar_is_back_center(center)
    return center and (center.set == "Back" or center.object_type == "Back")
end

local function solar_is_card_sleeves_grid_card(card)
    local area_config = card and card.area and card.area.config
    return area_config
        and area_config.type == "deck"
        and area_config.index
        and area_config.deck_height == 0.35
        and area_config.thin_draw == 1
end

local function solar_back_center(card)
    if not card then
        return nil
    end

    local params = card.params or {}
    if params.sleeve_card then
        return nil
    end

    if solar_is_card_sleeves_grid_card(card) then
        return nil
    end

    if params.galdur_back then
        if params.deck_select or params.deck_preview then
            return solar_center_from_back(params.galdur_back)
        end
        return nil
    end

    if type(params.viewed_back) == "table" then
        return solar_center_from_back(params.viewed_back)
    end

    local center = card.config and card.config.center
    if solar_is_back_center(center) then
        return center
    end

    return G and G.GAME and card.back and G.GAME[card.back] and solar_center_from_back(G.GAME[card.back])
end

local function solar_is_displayed_back(card)
    local center = solar_back_center(card)
    return center and center.key == "b_vegasstuff_solar_deck"
end

local function solar_draw_rings(sprite, card)
    if sprite then
        local send = card and card.ARGS and card.ARGS.send_to_shader or nil
        sprite:draw_shader("vegasstuff_solar_rings", nil, send, nil, sprite, SOLAR_RING_DRAW_SCALE, 0)
    end
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

    SMODS.DrawStep {
        key = "solar_deck_rings",
        order = 1,
        func = function(card)
            if solar_is_displayed_back(card) and card.children and card.children.back then
                solar_draw_rings(card.children.back, card)
            end
        end,
        conditions = { vortex = false, facing = "back" },
    }

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
            [1] = "{C:attention}Blind rewards{} become {C:attention}Astro Tags{}",
            [2] = "Earn {C:money}$0{} and skip the {C:attention}Shop{}",
            [3] = "{C:attention}Astro Tags{} open free {C:vegasstuff_geomancy}Astro Packs{}"
        }
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = "GeomancyCards",
    draw = function(self, card, layer)
        if solar_is_displayed_back(card) and card.children and card.children.center then
            solar_draw_rings(card.children.center, card)
        end
    end,
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
