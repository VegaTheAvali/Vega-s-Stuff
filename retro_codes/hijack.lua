local function hijack_selected_joker(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.jokers }, card, 1, 1, function(joker)
        return joker
            and joker.ability
            and joker.ability.set == "Joker"
            and not joker.getting_sliced
    end)
end

local function hijack_has_room()
    return G
        and G.jokers
        and G.jokers.cards
        and G.jokers.config
        and #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit
end

local function hijack_copy_snapshot()
    local snapshot = G and G.GAME and G.GAME.vegasstuff_hijack_snapshot
    if not snapshot then
        return
    end

    G.GAME.vegasstuff_hijack_snapshot = nil

    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 0.25,
        func = function()
            if not hijack_has_room() then
                return true
            end

            local joker = copy_card(snapshot)
            joker:set_edition({ negative = true }, true, true)
            joker:add_to_deck()
            G.jokers:emplace(joker)
            joker:juice_up(0.3, 0.5)
            snapshot:start_dissolve(nil, true)
            return true
        end
    }))
end

if not _G.vegasstuff_hijack_hooks_installed then
    _G.vegasstuff_hijack_hooks_installed = true

    local set_blind_ref = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        local results = { set_blind_ref(self, blind, reset, silent) }

        if blind and not reset and self.boss and G and G.GAME and G.GAME.vegasstuff_hijack_snapshot then
            if G.GAME.blind and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
            end
            hijack_copy_snapshot()
        end

        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "hijack",
    loc_txt = {
        name = "://HIJACK",
        text = {
            "Select a {C:attention}Joker{}",
            "The next {C:attention}Boss Blind{} is disabled",
            "Create a {C:dark_edition}Negative{} copy",
            "of the {C:attention}selected Joker{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #hijack_selected_joker(card) == 1
    end,
    use = function(self, card)
        local joker = hijack_selected_joker(card)[1]
        if not joker then
            return
        end

        G.GAME.vegasstuff_hijack_snapshot = copy_card(joker)
        joker:juice_up(0.3, 0.5)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 15)
