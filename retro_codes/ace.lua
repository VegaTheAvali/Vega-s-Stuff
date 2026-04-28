local function ace_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 1, 1, function(target)
        return target and target.playing_card
    end)
end

if not _G.vegasstuff_ace_hooks_installed then
    _G.vegasstuff_ace_hooks_installed = true
    local unpack_fn = table.unpack or unpack

    local is_suit_ref = Card.is_suit
    function Card:is_suit(suit, bypass_debuff, flush_calc)
        if self.ability and self.ability.vegasstuff_ace then
            return true
        end
        return is_suit_ref(self, suit, bypass_debuff, flush_calc)
    end

    local is_face_ref = Card.is_face
    function Card:is_face(from_boss)
        if self.ability and self.ability.vegasstuff_ace and (not self.debuff or from_boss) then
            return true
        end
        return is_face_ref(self, from_boss)
    end

    local end_round_ref = end_round
    function end_round(...)
        local results = { end_round_ref(...) }

        if G and G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.ability and playing_card.ability.vegasstuff_ace then
                    playing_card.ability.vegasstuff_ace = nil
                end
            end
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "ace",
    loc_txt = {
        name = "://ACE",
        text = {
            "Select a {C:attention}playing card{}",
            "Until {C:attention}end of round{}, it is",
            "{C:attention}every suit{} and a {C:attention}face card{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #ace_selected_card(card) == 1
    end,
    use = function(self, card, area, copier)
        local cards = ace_selected_card(card)
        if cards[1] then
            cards[1].ability.vegasstuff_ace = true
            cards[1]:juice_up(0.3, 0.5)
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 5)
