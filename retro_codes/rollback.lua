local ROLLBACK_HANDS = 1

local function rollback_visible_areas()
    return {
        G.hand,
        G.jokers,
        G.consumeables,
        G.pack_cards
    }
end

local function rollback_clear_debuffs()
    for _, area in ipairs(rollback_visible_areas()) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                if card.facing == "back" and card.flip then
                    card:flip()
                end
                card.debuff = false
                card.cry_debuff_immune = true
                if card.juice_up then
                    card:juice_up(0.2, 0.35)
                end
            end
        end
    end
end

local function rollback_discard_to_hand()
    if not (G and G.discard and G.discard.cards and G.hand) then
        return
    end

    local discard_count = #G.discard.cards
    for i = 1, discard_count do
        local card = G.discard.cards[#G.discard.cards]
        if card then
            if card.facing == "back" and card.flip then
                card:flip()
            end
            draw_card(G.discard, G.hand, i * 100 / math.max(discard_count, 1), "up", true, card)
        end
    end
end

Vegasstuff.retro_code_consumable({
    key = "rollback",
    loc_txt = {
        name = "://ROLLBACK",
        text = {
            "Clear visible {C:red}debuffs{}",
            "Return your {C:attention}discard pile{} to {C:attention}hand{}",
            "Gain {C:blue}+#1#{} {C:attention}hand{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            hands = ROLLBACK_HANDS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.hands } }
    end,
    can_use = function()
        return G and G.GAME and Cryptid.safe_get(G.GAME, "blind", "in_blind") and not G.GAME.USING_RUN
    end,
    use = function(self)
        rollback_clear_debuffs()
        rollback_discard_to_hand()
        ease_hands_played(self.config.extra.hands)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 14)
