local function build_selected_joker(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.jokers }, card, 1, 1, function(joker)
        return joker
            and joker.ability
            and joker.ability.set == "Joker"
            and not (Card.no and Card.no(joker, "immutable", true))
    end)
end

Vegasstuff.retro_code_consumable({
    key = "build",
    loc_txt = {
        name = "://BUILD",
        text = {
            "Select a {C:attention}Joker{}",
            "Add {C:cry_code}+1{} to its",
            "{C:cry_code}listed values{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #build_selected_joker(card) == 1
    end,
    use = function(self, card, area, copier)
        local joker = build_selected_joker(card)[1]
        if not joker then
            return
        end

        Cryptid.manipulate(joker, {
            type = "+",
            value = 1
        })

        if joker.juice_up then
            joker:juice_up(0.3, 0.5)
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 8)
