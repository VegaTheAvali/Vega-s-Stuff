local REPLAY_DOLLARS_PER_CARD = 1

local function replay_consumable_room()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return G.consumeables.config.card_limit - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0)
end

local function replay_joker_room()
    if not (G and G.jokers and G.jokers.cards and G.jokers.config) then
        return 0
    end

    return G.jokers.config.card_limit - #G.jokers.cards - (G.GAME.joker_buffer or 0)
end

local function replay_make_negative(card)
    if card and card.set_edition then
        card:set_edition({ negative = true }, true, true)
        if card.juice_up then
            card:juice_up(0.3, 0.5)
        end
    end
end

local function replay_create_joker(seed)
    if replay_joker_room() <= 0 then
        return
    end

    local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, seed)
    joker:add_to_deck()
    G.jokers:emplace(joker)
    replay_make_negative(joker)
end

local function replay_random_consumable(seed)
    if Cryptid and Cryptid.random_consumable then
        return Cryptid.random_consumable(seed, nil, "c_vegasstuff_replay")
    end
end

local function replay_create_consumable(seed)
    if replay_consumable_room() <= 0 then
        return
    end

    local center = replay_random_consumable(seed)
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
    replay_make_negative(consumable)
end

local function replay_retro_code_key(seed)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_replay" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed(seed))
end

local function replay_create_retro_code(seed)
    if replay_consumable_room() <= 0 then
        return
    end

    local key = replay_retro_code_key(seed)
    if not key then
        return
    end

    local retro = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
    replay_make_negative(retro)
end

local function replay_retro_codes_used()
    local total = 0

    if G and G.GAME and G.GAME.consumeable_usage and G.P_CENTERS then
        for key, usage in pairs(G.GAME.consumeable_usage) do
            local center = G.P_CENTERS[key]
            if center and center.set == Vegasstuff.RETRO_CODE_SET then
                total = total + (usage.count or 0)
            end
        end
    end

    return total
end

local function replay_cards_played()
    return G
        and G.GAME
        and G.GAME.round_scores
        and G.GAME.round_scores.cards_played
        and G.GAME.round_scores.cards_played.amt
        or 0
end

local function replay_bosses_defeated()
    local tracked = G and G.GAME and G.GAME.vegasstuff_bosses_defeated or 0
    local ante_proxy = G and G.GAME and G.GAME.round_resets and (G.GAME.round_resets.ante - 1) or 0
    return math.max(tracked, ante_proxy)
end

local function replay_antes_reached()
    return G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 1
end

if not _G.vegasstuff_replay_hooks_installed then
    _G.vegasstuff_replay_hooks_installed = true
    local unpack_fn = table.unpack or unpack

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local blind_on_deck = G and G.GAME and G.GAME.blind_on_deck
        local results = { evaluate_round_ref(...) }

        if blind_on_deck == "Boss" then
            G.GAME.vegasstuff_bosses_defeated = (G.GAME.vegasstuff_bosses_defeated or 0) + 1
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "replay",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            dollars_per_card = REPLAY_DOLLARS_PER_CARD
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.dollars_per_card } }
    end,
    can_use = function()
        return true
    end,
    use = function()
        local boss_count = replay_bosses_defeated()
        local ante_count = replay_antes_reached()
        local retro_count = replay_retro_codes_used()
        local card_dollars = replay_cards_played() * REPLAY_DOLLARS_PER_CARD

        for i = 1, boss_count do
            replay_create_joker("vegasstuff_replay_joker_" .. i)
        end

        for i = 1, ante_count do
            replay_create_consumable("vegasstuff_replay_consumable_" .. i)
        end

        for i = 1, retro_count do
            replay_create_retro_code("vegasstuff_replay_retro_" .. i)
        end

        if card_dollars > 0 then
            ease_dollars(card_dollars)
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 26)
