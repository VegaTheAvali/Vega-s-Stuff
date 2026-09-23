-- Boss Blinds

local DEJA_VU_SUITS = {
    Hearts = "vegasstuff_Cups",
    vegasstuff_Cups = "Hearts",

    Clubs = "vegasstuff_Wands",
    vegasstuff_Wands = "Clubs",

    Diamonds = "vegasstuff_Pentacles",
    vegasstuff_Pentacles = "Diamonds",

    Spades = "vegasstuff_Swords",
    vegasstuff_Swords = "Spades",
}


local function swap_deja_vu_suit(card)
    if not (card and card.base and card.base.suit) then
        return
    end

    local new_suit = DEJA_VU_SUITS[card.base.suit]

    if new_suit then
        SMODS.change_base(card, new_suit)
    end
end


local function deja_vu_selected_id(card)
    return card.playing_card or tostring(card)
end


local function update_deja_vu_selection(blind, cards)
    blind.effect.vegasstuff_deja_selected =
        blind.effect.vegasstuff_deja_selected or {}

    local previous = blind.effect.vegasstuff_deja_selected
    local current = {}
    local newly_selected = false

    for _, card in ipairs(cards or {}) do
        local id = deja_vu_selected_id(card)
        current[id] = true

        if not previous[id] then
            newly_selected = true
        end
    end

    if newly_selected then
        for _, card in ipairs(cards or {}) do
            swap_deja_vu_suit(card)
        end

        blind.triggered = true
        blind:wiggle()
    end

    blind.effect.vegasstuff_deja_selected = current
end


local GEOMANCY_KEYS = {
    "sol",
    "terra",
    "mars",
    "luna",
    "neptunus",
    "venus",
    "pluto",
    "mercurius",
    "saturnus",
    "uranus",
    "jupiter",
    "singularity",
}


local function total_geomancy_levels()
    local total = 0

    for _, key in ipairs(GEOMANCY_KEYS) do
        total = total + Vegasstuff.get_geomancy_level(key)
    end

    return total
end


local function increase_blind_for_suit(suit)
    if not (G and G.GAME and G.GAME.blind and G.play) then
        return
    end

    local blind = G.GAME.blind
    blind.effect.vegasstuff_base_chips =
        blind.effect.vegasstuff_base_chips or blind.chips

    local count = 0

    for _, card in ipairs(G.play.cards) do
        if card:is_suit(suit) then
            count = count + 1
        end
    end

    if count <= 0 then
        return
    end

    blind.chips =
        blind.chips
        + blind.effect.vegasstuff_base_chips * 0.05 * count

    blind.chip_text = number_format(blind.chips)
    blind.triggered = true
    blind:wiggle()
end


-- The Deja Vu Dream
SMODS.Blind {
    key = "deja_vu_dream",

    atlas = "BossBlinds",
    pos = { x = 0, y = 0 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("D29A6C"),

    set_blind = function(self)
        G.GAME.blind.effect.vegasstuff_deja_selected = {}
    end,

    debuff_hand = function(self, cards, hand, handname, check)
        if check then
            update_deja_vu_selection(G.GAME.blind, cards)
        end

        return false
    end,

    press_play = function(self)
        if not (G and G.play) then
            return
        end

        for _, card in ipairs(G.play.cards) do
            swap_deja_vu_suit(card)
        end

        G.GAME.blind.effect.vegasstuff_deja_selected = {}
        G.GAME.blind.triggered = true
        G.GAME.blind:wiggle()
    end,
}


-- The Water Web
SMODS.Blind {
    key = "water_web",

    atlas = "BossBlinds",
    pos = { x = 0, y = 1 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("76CAD8"),

    set_blind = function(self)
        local levels = total_geomancy_levels()

        if levels > 0 then
            ease_dollars(-levels)

            G.GAME.blind.triggered = true
            G.GAME.blind:wiggle()
        end
    end,
}


-- The Broken Break
SMODS.Blind {
    key = "broken_break",

    atlas = "BossBlinds",
    pos = { x = 0, y = 2 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("829195"),

    calculate = function(self, blind, context)
        if context.destroy_card
            and context.destroying_card
            and context.destroy_card.config
            and context.destroy_card.config.center
            and context.destroy_card.config.center.set == "Enhanced" then

            blind.triggered = true

            return {
                remove = true
            }
        end
    end,
}


-- The
SMODS.Blind {
    key = "the",

    atlas = "BossBlinds",
    pos = { x = 0, y = 3 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("11191C"),

    in_pool = function(self)
        return false
    end,
}


-- The Eclipse East
SMODS.Blind {
    key = "eclipse_east",

    atlas = "BossBlinds",
    pos = { x = 0, y = 4 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("425C64"),

    set_blind = function(self)
        G.GAME.blind.effect.vegasstuff_base_chips =
            G.GAME.blind.chips
    end,

    press_play = function(self)
        increase_blind_for_suit("Clubs")
    end,
}


-- The Wham West
SMODS.Blind {
    key = "wham_west",

    atlas = "BossBlinds",
    pos = { x = 0, y = 5 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("99E553"),

    set_blind = function(self)
        G.GAME.blind.effect.vegasstuff_base_chips =
            G.GAME.blind.chips
    end,

    press_play = function(self)
        increase_blind_for_suit("Spades")
    end,
}


-- The Sade South
SMODS.Blind {
    key = "sade_south",

    atlas = "BossBlinds",
    pos = { x = 0, y = 6 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("D64C70"),

    set_blind = function(self)
        G.GAME.blind.effect.vegasstuff_base_chips =
            G.GAME.blind.chips
    end,

    press_play = function(self)
        increase_blind_for_suit("Diamonds")
    end,
}


-- The Neon North
SMODS.Blind {
    key = "neon_north",

    atlas = "BossBlinds",
    pos = { x = 0, y = 7 },

    boss = { min = 1 },
    mult = 2,
    dollars = 5,
    boss_colour = HEX("48CF98"),

    set_blind = function(self)
        G.GAME.blind.effect.vegasstuff_base_chips =
            G.GAME.blind.chips
    end,

    press_play = function(self)
        increase_blind_for_suit("Hearts")
    end,
}


