local SPAWN_SELECTION_BONUS = 1

local function spawn_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 1, 1, function(target)
        return target and target.playing_card and target.base
    end)
end

local function spawn_collect_matching_cards(selected)
    local matches = {}
    local seen = {}

    if not (G and G.deck and G.deck.cards and selected and selected.base) then
        return matches
    end

    for _, deck_card in ipairs(G.deck.cards) do
        if deck_card.base and deck_card.base.value == selected.base.value and not seen[deck_card] then
            matches[#matches + 1] = deck_card
            seen[deck_card] = true
        end
    end

    for _, deck_card in ipairs(G.deck.cards) do
        if deck_card.base and deck_card.base.suit == selected.base.suit and not seen[deck_card] then
            matches[#matches + 1] = deck_card
            seen[deck_card] = true
        end
    end

    return matches
end

local function spawn_draw_matches(selected)
    local matches = spawn_collect_matching_cards(selected)
    for _, deck_card in ipairs(matches) do
        draw_card(G.deck, G.hand, nil, nil, false, deck_card)
    end
    return #matches
end

local function spawn_apply_selection_bonus()
    if not (G and G.GAME and SMODS and SMODS.change_play_limit and SMODS.change_discard_limit) then
        return
    end

    G.GAME.vegasstuff_spawn_selection_bonus = (G.GAME.vegasstuff_spawn_selection_bonus or 0) + SPAWN_SELECTION_BONUS
    SMODS.change_play_limit(SPAWN_SELECTION_BONUS)
    SMODS.change_discard_limit(SPAWN_SELECTION_BONUS)
end

local function spawn_clear_selection_bonus()
    if not (G and G.GAME and SMODS and SMODS.change_play_limit and SMODS.change_discard_limit) then
        return
    end

    local bonus = G.GAME.vegasstuff_spawn_selection_bonus or 0
    if bonus <= 0 then
        return
    end

    SMODS.change_play_limit(-bonus)
    SMODS.change_discard_limit(-bonus)
    G.GAME.vegasstuff_spawn_selection_bonus = 0
end

if not _G.vegasstuff_spawn_hooks_installed then
    _G.vegasstuff_spawn_hooks_installed = true

    local end_round_ref = end_round
    function end_round(...)
        local results = { end_round_ref(...) }
        spawn_clear_selection_bonus()
        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "spawn",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            selection_bonus = SPAWN_SELECTION_BONUS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.selection_bonus } }
    end,
    can_use = function(self, card)
        return #spawn_selected_card(card) == 1
    end,
    use = function(self, card)
        local cards = spawn_selected_card(card)
        if cards[1] then
            spawn_draw_matches(cards[1])
            spawn_apply_selection_bonus()
            cards[1]:juice_up(0.3, 0.5)
            G.hand:unhighlight_all()
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 18)
