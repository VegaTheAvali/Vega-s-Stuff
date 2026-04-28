local KLUDGE_VALUE_GAIN = 1

local function kludge_has_room()
    return G
        and G.jokers
        and G.jokers.cards
        and G.jokers.config
        and #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit
end

local function is_food_joker(joker)
    if not (joker and joker.config and joker.config.center) then
        return false
    end

    local center = joker.config.center
    return center.set == "Food"
        or (center.pools and center.pools.Food)
        or (joker.ability and joker.ability.set == "Food")
end

local function kludge_build_food_jokers()
    if not (G and G.jokers and G.jokers.cards) then
        return
    end

    for _, joker in ipairs(G.jokers.cards) do
        if is_food_joker(joker) and not (Card.no and Card.no(joker, "immutable", true)) then
            Cryptid.manipulate(joker, {
                type = "+",
                value = KLUDGE_VALUE_GAIN
            })
            if joker.juice_up then
                joker:juice_up(0.2, 0.4)
            end
        end
    end
end

Vegasstuff.retro_code_consumable({
    key = "kludge",
    loc_txt = {
        name = "://KLUDGE",
        text = {
            "Create a random {C:attention}Food Joker{}",
            "Add {C:cry_code}+#1#{} {C:cry_code}listed values{}",
            "to all {C:attention}Food Jokers{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            value_gain = KLUDGE_VALUE_GAIN
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.value_gain } }
    end,
    can_use = function()
        return kludge_has_room()
    end,
    use = function()
        local food_joker = create_card("Food", G.jokers, nil, nil, nil, nil, nil, "vegasstuff_kludge")
        food_joker:add_to_deck()
        G.jokers:emplace(food_joker)
        kludge_build_food_jokers()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 12)
