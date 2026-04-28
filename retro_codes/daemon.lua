local DAEMON_JOKER_BUFF = 1

local function daemon_state()
    if not (G and G.GAME and G.GAME.round_resets) then
        return nil
    end

    G.GAME.vegasstuff_daemon = G.GAME.vegasstuff_daemon or {
        ante = G.GAME.round_resets.ante,
        processes = 0
    }

    if G.GAME.vegasstuff_daemon.ante ~= G.GAME.round_resets.ante then
        G.GAME.vegasstuff_daemon = {
            ante = G.GAME.round_resets.ante,
            processes = 0
        }
    end

    return G.GAME.vegasstuff_daemon
end

local function daemon_hand_needs_cards()
    return G
        and G.hand
        and G.hand.cards
        and G.hand.config
        and G.deck
        and G.deck.cards
        and #G.hand.cards < G.hand.config.card_limit
        and #G.deck.cards > 0
end

local function daemon_draw_to_full()
    if not daemon_hand_needs_cards() then
        return false
    end

    local needed = G.hand.config.card_limit - #G.hand.cards
    for _ = 1, math.min(needed, #G.deck.cards) do
        draw_card(G.deck, G.hand, nil, nil, false, G.deck.cards[1])
    end

    return true
end

local function daemon_joker_room()
    return G
        and G.jokers
        and G.jokers.cards
        and G.jokers.config
        and #G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit
end

local function daemon_create_joker()
    if not daemon_joker_room() then
        return false
    end

    local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "vegasstuff_daemon")
    joker:add_to_deck()
    G.jokers:emplace(joker)
    joker:juice_up(0.3, 0.5)
    return true
end

local function daemon_consumable_room()
    return G
        and G.consumeables
        and G.consumeables.cards
        and G.consumeables.config
        and #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit
end

local function daemon_create_consumable()
    if not daemon_consumable_room() then
        return false
    end

    local center
    if Cryptid and Cryptid.random_consumable then
        center = Cryptid.random_consumable("vegasstuff_daemon", nil, "c_vegasstuff_daemon")
    end

    local consumable = create_card(
        center and center.set or "Consumeables",
        G.consumeables,
        nil,
        nil,
        nil,
        nil,
        center and center.key or nil,
        "vegasstuff_daemon"
    )
    consumable:add_to_deck()
    G.consumeables:emplace(consumable)
    consumable:juice_up(0.3, 0.5)
    return true
end

local function daemon_buffable_jokers()
    local choices = {}

    if G and G.jokers and G.jokers.cards then
        for _, joker in ipairs(G.jokers.cards) do
            if joker
                and joker.ability
                and joker.ability.set == "Joker"
                and not joker.getting_sliced
                and not (Card.no and Card.no(joker, "immutable", true))
            then
                choices[#choices + 1] = joker
            end
        end
    end

    return choices
end

local function daemon_buff_joker()
    if not (Cryptid and Cryptid.manipulate) then
        return false
    end

    local choices = daemon_buffable_jokers()
    if #choices == 0 then
        return false
    end

    local joker = pseudorandom_element(choices, pseudoseed("vegasstuff_daemon_buff"))
    Cryptid.manipulate(joker, {
        type = "+",
        value = DAEMON_JOKER_BUFF
    })
    joker:juice_up(0.3, 0.5)
    return true
end

local function daemon_run_one_job()
    if daemon_draw_to_full() then
        return
    end

    if daemon_create_joker() then
        return
    end

    if daemon_create_consumable() then
        return
    end

    daemon_buff_joker()
end

local function daemon_run_processes()
    local state = daemon_state()
    if not (state and state.processes and state.processes > 0) then
        return
    end

    for _ = 1, state.processes do
        daemon_run_one_job()
    end
end

if not _G.vegasstuff_daemon_hooks_installed then
    _G.vegasstuff_daemon_hooks_installed = true

    local set_blind_ref = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        local results = { set_blind_ref(self, blind, reset, silent) }

        if blind and not reset then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.25,
                func = function()
                    daemon_run_processes()
                    return true
                end
            }))
        end

        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "daemon",
    loc_txt = {
        name = "://DAEMON",
        text = {
            "Start a {C:green}background process{}",
            "for the rest of this {C:attention}Ante{}",
            "At each {C:attention}Blind{}, run the first",
            "available job:",
            "draw to full {C:attention}hand{}, create a {C:attention}Joker{},",
            "create a {C:attention}consumable{}, or add",
            "{C:cry_code}+#1#{} {C:cry_code}listed values{}",
            "to a random {C:attention}Joker{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            joker_buff = DAEMON_JOKER_BUFF
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.joker_buff } }
    end,
    can_use = function()
        return true
    end,
    use = function()
        local state = daemon_state()
        if state then
            state.processes = (state.processes or 0) + 1
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 20)
