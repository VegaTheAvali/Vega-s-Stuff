local BOOTLOOP_LOOPS = 3

local function bootloop_hand_size()
    if not (G and G.hand and G.hand.config) then
        return 0
    end

    return math.max(0, tonumber(G.hand.config.card_limit) or 0)
end

local function bootloop_move_area_to_deck(area, direction, delay)
    if not (area and area.cards and G and G.deck) then
        return
    end

    local count = #area.cards
    for i = 1, count do
        draw_card(area, G.deck, i * 100 / count, direction or "down", nil, nil, delay or 0.05)
    end
end

local function bootloop_reset_resources()
    if not (G and G.GAME and G.GAME.current_round and G.GAME.round_resets and G.GAME.round_bonus) then
        return
    end

    local target_discards = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
    local target_hands = math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands)

    ease_discard(target_discards - G.GAME.current_round.discards_left)
    ease_hands_played(target_hands - G.GAME.current_round.hands_left)
end

local function bootloop_snapshot_ghost_hand(loop_index)
    local ghosts = {}
    local hand_size = bootloop_hand_size()

    if G and G.deck and G.deck.cards then
        for i = 1, math.min(hand_size, #G.deck.cards) do
            local card = G.deck.cards[#G.deck.cards - i + 1]
            if card and card.ability then
                ghosts[#ghosts + 1] = card
            end
        end
    end

    if G and G.GAME then
        G.GAME.vegasstuff_bootloop_ghost_hands = G.GAME.vegasstuff_bootloop_ghost_hands or {}
        G.GAME.vegasstuff_bootloop_ghost_hands[#G.GAME.vegasstuff_bootloop_ghost_hands + 1] = ghosts
    end
end

local function bootloop_prepare_ghosts()
    if not (G and G.GAME and G.deck) then
        return
    end

    G.GAME.vegasstuff_bootloop_ghost_hands = {}
    G.GAME.vegasstuff_bootloop_active = true

    for i = 1, BOOTLOOP_LOOPS do
        G.deck:shuffle("vegasstuff_bootloop_" .. tostring(G.GAME.round_resets.ante) .. "_" .. tostring(i))
        bootloop_snapshot_ghost_hand(i)
    end
end

local function bootloop_context_copy(context)
    local copy = {}
    for key, value in pairs(context or {}) do
        copy[key] = value
    end

    copy.cardarea = G.play
    copy.vegasstuff_bootloop_phantom = true
    return copy
end

local function bootloop_score_ghosts(context)
    if not (G and G.GAME and G.GAME.vegasstuff_bootloop_active) then
        return
    end

    local ghost_hands = G.GAME.vegasstuff_bootloop_ghost_hands or {}
    G.GAME.vegasstuff_bootloop_active = nil
    G.GAME.vegasstuff_bootloop_ghost_hands = nil

    local score_card_ref = _G.vegasstuff_bootloop_score_card_ref
    if not score_card_ref then
        return
    end

    local ghost_context = bootloop_context_copy(context)
    for _, ghost_hand in ipairs(ghost_hands) do
        for _, ghost_card in ipairs(ghost_hand) do
            if ghost_card and ghost_card.ability and not ghost_card.destroyed and not ghost_card.shattered then
                score_card_ref(ghost_card, ghost_context)
                if ghost_card.juice_up then
                    ghost_card:juice_up(0.15, 0.25)
                end
            end
        end
    end
end

local function bootloop_reboot()
    bootloop_move_area_to_deck(G.hand, "down", 0.05)
    bootloop_move_area_to_deck(G.play, "down", 0.05)
    bootloop_move_area_to_deck(G.discard, "up", 0.005)
    bootloop_reset_resources()

    if G and G.playing_cards then
        for _, card in ipairs(G.playing_cards) do
            if card.ability then
                card.ability.wheel_flipped = nil
            end
        end
    end

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.25,
        func = function()
            bootloop_prepare_ghosts()
            G.STATE = G.STATES.DRAW_TO_HAND
            if G.deck then
                G.deck:hard_set_T()
            end
            G.STATE_COMPLETE = false
            return true
        end
    }))
end

if not _G.vegasstuff_bootloop_hooks_installed then
    _G.vegasstuff_bootloop_hooks_installed = true
    _G.vegasstuff_bootloop_score_card_ref = SMODS.score_card

    function SMODS.score_card(card, context)
        _G.vegasstuff_bootloop_score_card_ref(card, context)

        if not (context and context.cardarea == G.play and not context.vegasstuff_bootloop_phantom) then
            return
        end

        bootloop_score_ghosts(context)
    end
end

Vegasstuff.retro_code_consumable({
    key = "bootloop",
    loc_txt = {
        name = "://BOOTLOOP",
        text = {
            "Return {C:attention}hand{}, played, and",
            "discarded cards to {C:attention}deck{}",
            "Reset {C:blue}Hands{} and {C:red}Discards{},",
            "then reboot {C:attention}#1#{} times",
            "Each reboot saves a {C:attention}ghost hand{}",
            "Your next played {C:attention}hand{} also",
            "scores those {C:attention}ghost hands{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            loops = BOOTLOOP_LOOPS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.loops } }
    end,
    can_use = function()
        return G and G.STATE == G.STATES.SELECTING_HAND
    end,
    use = function()
        bootloop_reboot()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 33)
