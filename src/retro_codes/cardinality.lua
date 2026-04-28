local CARDINALITY_REWARD_DIVISOR = 10

local function cardinality_area_count(area)
    return area and area.cards and #area.cards or 0
end

local function cardinality_owned_count()
    return cardinality_area_count(G.deck)
        + cardinality_area_count(G.hand)
        + cardinality_area_count(G.play)
        + cardinality_area_count(G.discard)
        + cardinality_area_count(G.jokers)
        + cardinality_area_count(G.consumeables)
end

local function cardinality_make_negative(card)
    if card and card.set_edition then
        card:set_edition({ negative = true }, true, true)
        if card.juice_up then
            card:juice_up(0.3, 0.5)
        end
    end
end

local function cardinality_random_retro_code_key(seed)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_cardinality" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed(seed))
end

local function cardinality_random_consumable(seed)
    if Cryptid and Cryptid.random_consumable then
        return Cryptid.random_consumable(seed, nil, "c_vegasstuff_cardinality")
    end
end

local function cardinality_ensure_joker_space(amount)
    if G and G.jokers and G.jokers.config then
        G.jokers.config.card_limit = G.jokers.config.card_limit + amount
    end
end

local function cardinality_ensure_consumable_space(amount)
    if G and G.consumeables and G.consumeables.config then
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + amount
    end
end

local function cardinality_create_joker(seed)
    cardinality_ensure_joker_space(1)
    local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, seed)
    joker:add_to_deck()
    G.jokers:emplace(joker)
    cardinality_make_negative(joker)
end

local function cardinality_create_consumable(seed)
    cardinality_ensure_consumable_space(1)
    local center = cardinality_random_consumable(seed)
    local consumable = create_card(
        center and center.set or "Consumeables",
        G.consumeables,
        nil,
        nil,
        nil,
        nil,
        center and center.key or nil,
        seed
    )
    consumable:add_to_deck()
    G.consumeables:emplace(consumable)
    cardinality_make_negative(consumable)
end

local function cardinality_create_retro_code(seed)
    local key = cardinality_random_retro_code_key(seed)
    if not key then
        return
    end

    cardinality_ensure_consumable_space(1)
    local retro = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
    cardinality_make_negative(retro)
end

local function cardinality_create_rewards(count)
    local rewards = math.floor(count / CARDINALITY_REWARD_DIVISOR)
    for i = 1, rewards do
        local slot = ((i - 1) % 3) + 1
        if slot == 1 then
            cardinality_create_joker("vegasstuff_cardinality_joker_" .. i)
        elseif slot == 2 then
            cardinality_create_consumable("vegasstuff_cardinality_consumable_" .. i)
        else
            cardinality_create_retro_code("vegasstuff_cardinality_retro_" .. i)
        end
    end
end

local function cardinality_reduce_blind(count)
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips and count > 0) then
        return
    end

    local new_chips = to_big(G.GAME.blind.chips) / to_big(count)
    if to_big(new_chips) < to_big(1) then
        new_chips = 1
    end

    G.GAME.blind.chips = Vegasstuff.to_number(new_chips, 1)
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
end

Vegasstuff.retro_code_consumable({
    key = "cardinality",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            divisor = CARDINALITY_REWARD_DIVISOR
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.divisor } }
    end,
    can_use = function()
        return cardinality_owned_count() > 0
    end,
    use = function()
        local count = cardinality_owned_count()
        if count <= 0 then
            return
        end

        if G.hand and G.hand.change_size then
            G.hand:change_size(count)
        end

        ease_dollars(count)
        cardinality_create_rewards(count)
        cardinality_reduce_blind(count)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 27)
