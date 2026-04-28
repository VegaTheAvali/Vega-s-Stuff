local FORK_SOLAR_TAG = "tag_vegasstuff_astro"
local FORK_SOLAR_SMALL_CHOICES = 3
local FORK_SOLAR_BOSS_CHOICES = 5

local function fork_active_state()
    if not (G and G.GAME) then
        return nil
    end

    G.GAME.vegasstuff_fork = G.GAME.vegasstuff_fork or {
        processes = 0,
        boss = false,
        boss_disabled = false
    }

    return G.GAME.vegasstuff_fork
end

local function fork_in_blind()
    return G
        and G.GAME
        and G.GAME.blind
        and G.GAME.blind.in_blind
end

local function fork_solar_active()
    return G
        and G.GAME
        and G.GAME.modifiers
        and G.GAME.modifiers.vegasstuff_solar_deck
end

local function fork_blind_reward_tag(blind_on_deck)
    return G
        and G.GAME
        and G.GAME.round_resets
        and G.GAME.round_resets.blind_tags
        and G.GAME.round_resets.blind_tags[blind_on_deck]
end

local function fork_add_tag(tag_key)
    if tag_key and G and G.P_TAGS and G.P_TAGS[tag_key] then
        add_tag(Tag(tag_key))
    end
end

local function fork_duplicate_reward(processes, dollars, blind_on_deck, boss)
    for _ = 1, processes do
        if fork_solar_active() then
            G.GAME.vegasstuff_solar_pending_choices = boss and FORK_SOLAR_BOSS_CHOICES or FORK_SOLAR_SMALL_CHOICES
            fork_add_tag(FORK_SOLAR_TAG)
        elseif dollars and dollars > 0 then
            ease_dollars(dollars)
        end

        fork_add_tag(fork_blind_reward_tag(blind_on_deck))
    end
end

local function fork_clear_state()
    if G and G.GAME then
        G.GAME.vegasstuff_fork = nil
    end
end

if not _G.vegasstuff_fork_hooks_installed then
    _G.vegasstuff_fork_hooks_installed = true
    local unpack_fn = table.unpack or unpack

    local evaluate_play_ref = G.FUNCS.evaluate_play
    function G.FUNCS.evaluate_play(e)
        local results = { evaluate_play_ref(e) }
        local state = G and G.GAME and G.GAME.vegasstuff_fork

        if state and state.processes > 0 and state.boss and not state.boss_disabled then
            state.boss_disabled = true
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.15,
                func = function()
                    if G.GAME.blind and not G.GAME.blind.disabled then
                        G.GAME.blind:disable()
                    end
                    return true
                end
            }))
        end

        return unpack_fn(results)
    end

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local state = G and G.GAME and G.GAME.vegasstuff_fork
        local processes = state and state.processes or 0
        local boss = state and state.boss
        local blind_on_deck = G and G.GAME and G.GAME.blind_on_deck
        local dollars = G and G.GAME and G.GAME.blind and G.GAME.blind.dollars or 0
        local results = { evaluate_round_ref(...) }

        if processes > 0 then
            fork_clear_state()
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.5,
                func = function()
                    fork_duplicate_reward(processes, dollars, blind_on_deck, boss)
                    return true
                end
            }))
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "fork",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return fork_in_blind()
    end,
    use = function()
        local state = fork_active_state()
        if not state then
            return
        end

        state.processes = (state.processes or 0) + 1
        state.boss = state.boss or (G.GAME.blind and G.GAME.blind.boss)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 21)
