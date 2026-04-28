local CONST_ENHANCEMENT = "m_steel"
local CONST_SEAL = "Red"

local function const_state()
    if not (G and G.GAME) then
        return nil
    end

    return G.GAME.vegasstuff_const
end

local function const_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 1, 1, function(target)
        return target and target.playing_card and target.base
    end)
end

local function const_apply_base(card, state)
    if not (card and card.playing_card and card.base and state and state.rank and state.suit) then
        return
    end

    if SMODS and SMODS.change_base then
        SMODS.change_base(card, state.suit, state.rank)
    end
end

local function const_apply_chosen_bonus(card)
    if not (card and card.playing_card) then
        return
    end

    if G.P_CENTERS and G.P_CENTERS[CONST_ENHANCEMENT] then
        card:set_ability(G.P_CENTERS[CONST_ENHANCEMENT])
    end

    card:set_edition({ polychrome = true }, true, true)
    card:set_seal(CONST_SEAL, true, true)

    if card.ability then
        card.ability.cry_rigged = true
        card.ability.cry_global_sticker = true
    end

    card:juice_up(0.3, 0.5)
end

local function const_apply_to_existing_cards(state)
    if not (G and G.playing_cards and state) then
        return
    end

    for _, playing_card in ipairs(G.playing_cards) do
        const_apply_base(playing_card, state)
    end
end

local function const_apply_to_future_card(card)
    local state = const_state()
    if not state then
        return
    end

    const_apply_base(card, state)
end

if not _G.vegasstuff_const_hooks_installed then
    _G.vegasstuff_const_hooks_installed = true

    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local results = { emplace_ref(self, card, ...) }
        const_apply_to_future_card(card)
        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "const",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #const_selected_card(card) == 1
    end,
    use = function(self, card)
        local selected = const_selected_card(card)[1]
        if not selected then
            return
        end

        G.GAME.vegasstuff_const = {
            rank = selected.base.value,
            suit = selected.base.suit
        }

        const_apply_to_existing_cards(G.GAME.vegasstuff_const)
        const_apply_chosen_bonus(selected)

        if G.hand then
            G.hand:unhighlight_all()
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 25)
