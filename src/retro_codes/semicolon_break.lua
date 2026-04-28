local BREAK_BOSS_REWARD_COUNT = 1

local function break_state()
    if not (G and G.GAME) then
        return nil
    end

    G.GAME.vegasstuff_semicolon_break = G.GAME.vegasstuff_semicolon_break or {}
    return G.GAME.vegasstuff_semicolon_break
end

local function break_consumable_room()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return G.consumeables.config.card_limit - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0)
end

local function break_expand_consumables(needed)
    if G and G.consumeables and G.consumeables.config and break_consumable_room() < needed then
        G.consumeables.config.card_limit = #G.consumeables.cards + needed
    end
end

local function break_random_retro_code_key()
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_break" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_semicolon_break_retro"))
end

local function break_create_retro_code()
    local key = break_random_retro_code_key()
    if not key then
        return
    end

    break_expand_consumables(1)
    local created = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })

    if created then
        created:juice_up(0.3, 0.5)
    end
end

local function break_reward_tag(blind_on_deck)
    return G
        and G.GAME
        and G.GAME.round_resets
        and G.GAME.round_resets.blind_tags
        and G.GAME.round_resets.blind_tags[blind_on_deck]
end

local function break_add_tag(tag_key)
    if tag_key and G and G.P_TAGS and G.P_TAGS[tag_key] then
        add_tag(Tag(tag_key))
    end
end

local function break_force_win_score()
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) then
        return
    end

    if to_big(G.GAME.chips or 0) < to_big(G.GAME.blind.chips) then
        G.GAME.chips = Vegasstuff.to_number(G.GAME.blind.chips, 1)
        G.GAME.chips_text = number_format(G.GAME.chips)
    end
end

local function break_apply_bonus_rewards(state)
    if not (state and state.active) then
        return
    end

    if state.dollars and state.dollars > 0 then
        ease_dollars(state.dollars)
    end

    break_add_tag(break_reward_tag(state.blind_on_deck))

    if state.boss then
        for _ = 1, BREAK_BOSS_REWARD_COUNT do
            break_create_retro_code()
        end
    end
end

if not _G.vegasstuff_semicolon_break_hooks_installed then
    _G.vegasstuff_semicolon_break_hooks_installed = true
    local unpack_fn = table.unpack or unpack

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local state = G and G.GAME and G.GAME.vegasstuff_semicolon_break
        local results = { evaluate_round_ref(...) }

        if state and state.active then
            G.GAME.vegasstuff_semicolon_break = nil
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.5,
                func = function()
                    break_apply_bonus_rewards(state)
                    return true
                end
            }))
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "break",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return G
            and G.STATE == G.STATES.SELECTING_HAND
            and G.GAME
            and G.GAME.blind
            and G.GAME.blind.in_blind
    end,
    use = function()
        local state = break_state()
        if not state then
            return
        end

        state.active = true
        state.boss = G.GAME.blind and G.GAME.blind.boss
        state.blind_on_deck = G.GAME.blind_on_deck
        state.dollars = G.GAME.blind and G.GAME.blind.dollars or 0

        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                if G.STATE ~= G.STATES.SELECTING_HAND then
                    return false
                end

                break_force_win_score()
                G.STATE = G.STATES.HAND_PLAYED
                G.STATE_COMPLETE = true
                end_round()
                return true
            end
        }), "other")
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 34)
