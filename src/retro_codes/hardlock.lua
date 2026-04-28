local HARDLOCK_DEBUFF_SOURCE = "vegasstuff_hardlock"
local unpack_fn = table.unpack or unpack

local function hardlock_selected_joker(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.jokers }, card, 1, 1, function(joker)
        return not (Card.no and Card.no(joker, "immutable", true))
    end)
end

local function clear_hardlock_debuff(joker)
    if not (joker and joker.ability and joker.ability.debuff_sources) then
        return
    end

    joker.ability.debuff_sources[HARDLOCK_DEBUFF_SOURCE] = nil
    joker.config.vegasstuff_hardlock_debuffed = nil
    joker:set_debuff(false)
end

if not _G.vegasstuff_hardlock_hooks_installed then
    _G.vegasstuff_hardlock_hooks_installed = true

    local end_round_ref = end_round
    function end_round(...)
        local results = { end_round_ref(...) }

        if G and G.jokers and G.jokers.cards then
            for _, joker in ipairs(G.jokers.cards) do
                if joker.config and joker.config.vegasstuff_hardlock_multiply then
                    local factor = joker.config.vegasstuff_hardlock_multiply
                    Cryptid.manipulate(joker, { value = 1 / factor })
                    joker.config.vegasstuff_hardlock_multiply = nil
                    joker.config.vegasstuff_hardlock_pending_debuff = true
                elseif joker.config and joker.config.vegasstuff_hardlock_debuffed then
                    clear_hardlock_debuff(joker)
                end
            end
        end

        return unpack_fn(results)
    end

    local set_blind_ref = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        local results = { set_blind_ref(self, blind, reset, silent) }

        if blind and not reset and G and G.jokers and G.jokers.cards then
            for _, joker in ipairs(G.jokers.cards) do
                if joker.config and joker.config.vegasstuff_hardlock_pending_debuff then
                    joker.config.vegasstuff_hardlock_pending_debuff = nil
                    joker.config.vegasstuff_hardlock_debuffed = true
                    joker.ability.debuff_sources = joker.ability.debuff_sources or {}
                    joker.ability.debuff_sources[HARDLOCK_DEBUFF_SOURCE] = true
                    joker:set_debuff(true)
                end
            end
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "hardlock",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #hardlock_selected_joker(card) == 1
    end,
    use = function(self, card, area, copier)
        local jokers = hardlock_selected_joker(card)
        local joker = jokers[1]
        if not joker then
            return
        end

        joker:set_edition({ cry_glitched = true })
        joker.config.vegasstuff_hardlock_multiply = (joker.config.vegasstuff_hardlock_multiply or 1) * 2
        Cryptid.manipulate(joker, { value = 2 })
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 2)
