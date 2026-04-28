local function push_selected_joker(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.jokers }, card, 1, 1, function(joker)
        return joker
            and joker.ability
            and joker.ability.set == "Joker"
            and not joker.getting_sliced
            and not (Card.no and Card.no(joker, "immutable", true))
    end)
end

local function lower_rarity_args(rarity)
    if rarity == 4 then
        return false, 0.99
    end
    if rarity == 3 then
        return false, 0.9
    end
    return false, 0
end

local function has_room_after_push()
    return G
        and G.jokers
        and G.jokers.cards
        and G.jokers.config
        and #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit
end

Vegasstuff.retro_code_consumable({
    key = "push",
    loc_txt = {
        name = "://PUSH",
        text = {
            "Destroy {C:attention}1{} {C:attention}selected Joker{}",
            "Create {C:attention}2{} random {C:attention}Jokers{}",
            "of one lower {C:attention}rarity{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        local jokers = push_selected_joker(card)
        return #jokers == 1
            and has_room_after_push()
            and not SMODS.is_eternal(jokers[1])
            and type(jokers[1].config.center.rarity) == "number"
            and jokers[1].config.center.rarity < 5
    end,
    use = function(self, card, area, copier)
        local joker = push_selected_joker(card)[1]
        if not joker then
            return
        end

        local legendary, rarity = lower_rarity_args(joker.config.center.rarity)
        joker.getting_sliced = true

        G.E_MANAGER:add_event(Event({
            trigger = "before",
            delay = 0.75,
            func = function()
                joker:start_dissolve()
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("timpani")
                for _ = 1, 2 do
                    local new_joker = create_card("Joker", G.jokers, legendary, rarity, nil, nil, nil, "vegasstuff_push")
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:juice_up(0.3, 0.5)
                end
                return true
            end
        }))
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 10)
