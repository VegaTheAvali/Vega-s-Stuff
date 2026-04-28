local ILOVEYOU_SPREAD_COUNT = 2

local function iloveyou_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 1, 1, function(target)
        return target and target.playing_card
    end)
end

local function deck_targets(source)
    local targets = {}

    if not (G and G.deck and G.deck.cards) then
        return targets
    end

    for _, deck_card in ipairs(G.deck.cards) do
        if deck_card ~= source and deck_card.playing_card then
            targets[#targets + 1] = deck_card
        end
    end

    return targets
end

local function copy_edition_to_random_deck_cards(source, count)
    if not source.edition then
        return
    end

    local targets = deck_targets(source)

    for i = 1, math.min(count, #targets) do
        local index = pseudorandom(pseudoseed("vegasstuff_iloveyou_" .. i), 1, #targets)
        local target = table.remove(targets, index)

        if target then
            target:set_edition(copy_table(source.edition), true)
            target:juice_up(0.3, 0.3)
        end
    end
end

Vegasstuff.retro_code_consumable({
    key = "iloveyou",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            spread = ILOVEYOU_SPREAD_COUNT
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.spread } }
    end,
    can_use = function(self, card)
        return #iloveyou_selected_card(card) == 1
    end,
    use = function(self, card, area, copier)
        local cards = iloveyou_selected_card(card)
        local source = cards[1]
        if not source then
            return
        end

        source:set_edition({ cry_glitched = true })
        source:juice_up(0.3, 0.5)
        copy_edition_to_random_deck_cards(source, self.config.extra.spread)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 6)
