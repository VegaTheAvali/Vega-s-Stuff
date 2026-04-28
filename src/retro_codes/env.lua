local function env_state()
    if not (G and G.GAME and G.GAME.round_resets) then
        return nil
    end

    local state = G.GAME.vegasstuff_env
    if state and state.ante ~= G.GAME.round_resets.ante then
        G.GAME.vegasstuff_env = nil
        return nil
    end

    return state
end

local function env_increment_count(counts, key)
    if not key then
        return
    end

    counts[key] = (counts[key] or 0) + 1
end

local function env_cards_played_for_rank(rank)
    return G
        and G.GAME
        and G.GAME.cards_played
        and G.GAME.cards_played[rank]
        and G.GAME.cards_played[rank].total
        or 0
end

local function env_cards_played_for_suit(suit)
    local total = 0

    if G and G.GAME and G.GAME.cards_played then
        for _, rank_data in pairs(G.GAME.cards_played) do
            if rank_data.suits and rank_data.suits[suit] then
                total = total + (rank_data.total or 0)
            end
        end
    end

    return total
end

local function env_best_from_counts(counts, usage_func)
    local best_key
    local best_count = -1
    local best_usage = -1

    for key, count in pairs(counts) do
        local usage = usage_func and usage_func(key) or 0
        if count > best_count or (count == best_count and usage > best_usage) then
            best_key = key
            best_count = count
            best_usage = usage
        end
    end

    return best_key
end

local function env_common_rank_and_suit()
    local ranks = {}
    local suits = {}

    if G and G.playing_cards then
        for _, card in ipairs(G.playing_cards) do
            if card.base then
                env_increment_count(ranks, card.base.value)
                env_increment_count(suits, card.base.suit)
            end
        end
    end

    return env_best_from_counts(ranks, env_cards_played_for_rank),
        env_best_from_counts(suits, env_cards_played_for_suit)
end

local function env_common_joker_rarity(card_to_ignore)
    local rarities = {}

    if G and G.jokers and G.jokers.cards then
        for _, joker in ipairs(G.jokers.cards) do
            if joker ~= card_to_ignore and joker.config and joker.config.center then
                env_increment_count(rarities, joker.config.center.rarity)
            end
        end
    end

    return env_best_from_counts(rarities)
end

local function env_consumable_usage(set_key)
    local usage = G and G.GAME and G.GAME.consumeable_usage_total
    if not (usage and set_key) then
        return 0
    end

    return usage[set_key] or usage[string.lower(set_key)] or 0
end

local function env_common_consumable_set(card_to_ignore)
    local sets = {}

    if G and G.consumeables and G.consumeables.cards then
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable ~= card_to_ignore and consumable.config and consumable.config.center then
                env_increment_count(sets, consumable.config.center.set)
            end
        end
    end

    return env_best_from_counts(sets, env_consumable_usage)
end

local function env_center_choices(set_key, filter_func)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[set_key]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center
                and not center.no_collection
                and not center.hidden
                and (not filter_func or filter_func(center))
            then
                choices[#choices + 1] = center
            end
        end
    end

    return choices
end

local function env_center_from_pool(set_key, seed, filter_func)
    local choices = env_center_choices(set_key, filter_func)
    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed(seed))
end

local function env_apply_playing_card(card)
    if not (card and card.playing_card and card.base and SMODS and SMODS.change_base) then
        return
    end

    local rank, suit = env_common_rank_and_suit()
    if rank and suit then
        SMODS.change_base(card, suit, rank)
        card:juice_up(0.15, 0.25)
    end
end

local function env_apply_joker(card)
    if not (card and card.ability and card.ability.set == "Joker") then
        return
    end

    local rarity = env_common_joker_rarity(card)
    if not rarity then
        return
    end

    local center = env_center_from_pool("Joker", "vegasstuff_env_joker", function(candidate)
        return candidate.rarity == rarity and candidate.key ~= card.config.center_key
    end)

    if center then
        card:set_ability(center)
        card:juice_up(0.3, 0.5)
    end
end

local function env_apply_consumable(card)
    if not (card and card.ability and card.ability.consumeable and card.config and card.config.center) then
        return
    end

    local set_key = env_common_consumable_set(card)
    if not set_key or set_key == card.config.center.set then
        return
    end

    local center = env_center_from_pool(set_key, "vegasstuff_env_consumable", function(candidate)
        return candidate.key ~= card.config.center_key
    end)

    if center then
        card:set_ability(center)
        card:juice_up(0.3, 0.5)
    end
end

local function env_apply_to_card(card)
    if not env_state() then
        return
    end

    if not (card and card.ability) then
        return
    end

    if card.ability.vegasstuff_env_applied then
        return
    end

    card.ability.vegasstuff_env_applied = true

    if card.playing_card then
        env_apply_playing_card(card)
    elseif card.ability.set == "Joker" then
        env_apply_joker(card)
    elseif card.ability.consumeable then
        env_apply_consumable(card)
    end
end

if not _G.vegasstuff_env_hooks_installed then
    _G.vegasstuff_env_hooks_installed = true

    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local results = { emplace_ref(self, card, ...) }
        env_apply_to_card(card)
        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "env",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return true
    end,
    use = function()
        G.GAME.vegasstuff_env = {
            ante = G.GAME.round_resets.ante
        }
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 24)
