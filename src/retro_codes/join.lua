local function join_selected_cards(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 2, 2, function(target)
        return target and target.playing_card
    end)
end

local function swap_card_data(left, right)
    local left_center = left.config and left.config.center or G.P_CENTERS.c_base
    local right_center = right.config and right.config.center or G.P_CENTERS.c_base
    local left_edition = left.edition and copy_table(left.edition) or nil
    local right_edition = right.edition and copy_table(right.edition) or nil
    local left_seal = left.seal
    local right_seal = right.seal

    left:set_ability(right_center, nil, true)
    right:set_ability(left_center, nil, true)

    left:set_edition(right_edition, true, true)
    right:set_edition(left_edition, true, true)

    left:set_seal(right_seal, true, true)
    right:set_seal(left_seal, true, true)

    left:juice_up(0.3, 0.5)
    right:juice_up(0.3, 0.5)
end

Vegasstuff.retro_code_consumable({
    key = "join",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #join_selected_cards(card) == 2
    end,
    use = function(self, card, area, copier)
        local cards = join_selected_cards(card)
        if cards[1] and cards[2] then
            swap_card_data(cards[1], cards[2])
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 9)
