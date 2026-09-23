do
local ALLOWED_SOURCES = {
    rif = true,
    rta = true,
    sou = true,
    uta = true,
    wra = true
}

SMODS.Joker {
    key = "theseized",
    
    pos = {
        x = 2,
        y = 0
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 250,
    rarity = "vegasstuff_jen_transcendent",
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    dependencies = { "Cryptid", "Polterworx" },
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    soul_pos = {
        x = 3,
        y = 0
    },
    in_pool = function(self, args)
        return not args or (args.source ~= 'sho' and args.source ~= 'buf' and args.source ~= 'jud') or ALLOWED_SOURCES[args.source]
    end
}
end

do
local VEGA_THRESHOLD = 5
local VEGA_DEFAULT_GEOMANCY_COUNT = 0
local VEGA_ALLOWED_SOURCES = {
    buf = true,
    jud = true,
    rif = true,
    rta = true,
    sou = true,
    uta = true,
    wra = true
}

local function vega_normalize_gain(value, fallback)
    local gain = math.max(0, tonumber(value) or fallback)
    if math.abs(gain) < 1e300 then
        gain = tonumber(string.format("%.2g", gain)) or gain
    end
    return gain
end

local function vega_format_gain_display(gain)
    if gain == math.floor(gain) then
        return tostring(math.floor(gain))
    end

    local text = string.format("%.2f", gain)
    while text:sub(-1) == "0" do
        text = text:sub(1, -2)
    end
    if text:sub(-1) == "." then
        text = text:sub(1, -2)
    end
    return text
end

local function vega_ensure_extra(self, card)
    card.ability.extra = card.ability.extra or {}
    if card.ability.extra.Geomancy_count == nil then
        card.ability.extra.Geomancy_count = card.ability.extra.Spec_count or VEGA_DEFAULT_GEOMANCY_COUNT
    end
    card.ability.extra.Spec_count = nil
    card.ability.extra.Geomancy_final = VEGA_THRESHOLD
    card.ability.extra.Spec_final = nil
    return card.ability.extra
end

local function vega_get_clamped_count(extra)
    local count = math.max(0, math.floor(tonumber(extra.Geomancy_count or extra.Spec_count or 0) or 0))
    return math.min(count, VEGA_THRESHOLD - 1)
end

local function vega_is_geomancy_consumable(consumeable)
    local ability_set = consumeable and consumeable.ability and consumeable.ability.set
    local center_set = consumeable and consumeable.config and consumeable.config.center and consumeable.config.center.set
    return ability_set == "geomancy" or center_set == "geomancy"
end

SMODS.Joker {
    key = "vega",
    config = {
        extra = {
            selection_gain = 1
        }
    },
    
    pos = {
        x = 0,
        y = 0
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 25,
    rarity = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    soul_pos = {
        x = 1,
        y = 0
    },
    in_pool = function(self, args)
        return not args or args.source ~= 'sho' or VEGA_ALLOWED_SOURCES[args.source]
    end,

    set_ability = function(self, card, initial, delay_sprites)
        local extra = vega_ensure_extra(self, card)
        extra.Geomancy_count = vega_get_clamped_count(extra)
        extra.selection_gain = vega_normalize_gain(extra.selection_gain or self.config.extra.selection_gain, self.config.extra.selection_gain)
        card.ability.extra = extra
    end,

    load = function(self, card, card_table, other_card)
        self:set_ability(card, false, false)
    end,

    loc_vars = function(self, info_queue, card)
        local extra = vega_ensure_extra(self, card)
        local count = vega_get_clamped_count(extra)
        local gain = vega_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
        extra.Geomancy_count = count
        return { vars = { count, VEGA_THRESHOLD, vega_format_gain_display(gain) } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and vega_is_geomancy_consumable(context.consumeable) then
            return {
                func = function()
                    local extra = vega_ensure_extra(self, card)
                    local current = vega_get_clamped_count(extra)
                    local gain_per_trigger = vega_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
                    local updated = current + 1

                    if gain_per_trigger > 0 and updated >= VEGA_THRESHOLD then
                        local triggers = math.floor(updated / VEGA_THRESHOLD)
                        -- Integer boundary: round half up (0.5 and above rounds up).
                        local total_gain = math.max(0, math.floor((triggers * gain_per_trigger) + 0.5))
                        extra.Geomancy_count = updated - (triggers * VEGA_THRESHOLD)
                        if total_gain > 0 then
                            SMODS.change_play_limit(total_gain)
                            SMODS.change_discard_limit(total_gain)
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(total_gain).." Selection", colour = G.C.BLUE})
                        end
                    else
                        extra.Geomancy_count = updated
                    end
                    return true
                end
            }
        end
    end
}
end


-- Hand Jokers. 

-- Posted Joker

SMODS.Joker {
    key = "posted",
    atlas = "HandJokers",
    pos = { x = 3, y = 0 },
    config = { extra = { bonus = 15 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.bonus }
        }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_postage"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_postage"]) then

            return {
                mult = card.ability.extra.bonus
            }
        end
    end,
}

-- Publicized Joker

SMODS.Joker {
    key = "publicized",
    atlas = "HandJokers",
    pos = { x = 3, y = 1 },
    config = { extra = { bonus = 100 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.bonus }
        }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_postage"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_postage"]) then

            return {
                chips = card.ability.extra.bonus
            }
        end
    end,
}

-- Caught Joker

SMODS.Joker {
    key = "caught",
    atlas = "HandJokers",
    pos = { x = 2, y = 0 },
    config = { extra = { bonus = 13 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_package"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_package"]) then
            return { mult = card.ability.extra.bonus }
        end
    end,
}


-- Captured Joker

SMODS.Joker {
    key = "captured",
    atlas = "HandJokers",
    pos = { x = 2, y = 1 },
    config = { extra = { bonus = 90 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_package"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_package"]) then
            return { chips = card.ability.extra.bonus }
        end
    end,
}


-- Clean Joker

SMODS.Joker {
    key = "clean",
    atlas = "HandJokers",
    pos = { x = 1, y = 0 },
    config = { extra = { bonus = 14 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_mint"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_mint"]) then
            return { mult = card.ability.extra.bonus }
        end
    end,
}


-- Fresh Joker

SMODS.Joker {
    key = "fresh",
    atlas = "HandJokers",
    pos = { x = 1, y = 1 },
    config = { extra = { bonus = 100 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_mint"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_mint"]) then
            return { chips = card.ability.extra.bonus }
        end
    end,
}


-- Bewitched Joker

SMODS.Joker {
    key = "bewitched",
    atlas = "HandJokers",
    pos = { x = 0, y = 0 },
    config = { extra = { bonus = 12 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_spell"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_spell"]) then
            return { mult = card.ability.extra.bonus }
        end
    end,
}


-- Enchanted Joker

SMODS.Joker {
    key = "enchanted",
    atlas = "HandJokers",
    pos = { x = 0, y = 1 },
    config = { extra = { bonus = 80 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_spell"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_spell"]) then
            return { chips = card.ability.extra.bonus }
        end
    end,
}


-- Spellbound Joker

SMODS.Joker {
    key = "spellbound",
    atlas = "HandJokers",
    pos = { x = 4, y = 0 },
    config = { extra = { bonus = 16 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_cauldron"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_cauldron"]) then
            return { mult = card.ability.extra.bonus }
        end
    end,
}


-- Hexed Joker

SMODS.Joker {
    key = "hexed",
    atlas = "HandJokers",
    pos = { x = 4, y = 1 },
    config = { extra = { bonus = 120 } },
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    unlocked = true,
    discovered = true,
    eternal_compat = true,
    perishable_compat = true,
    demicolon_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bonus } }
    end,

    in_pool = function(self, args)
        return G.GAME.hands["vegasstuff_cauldron"].played > 0
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and context.poker_hands ~= nil
            and next(context.poker_hands["vegasstuff_cauldron"]) then
            return { chips = card.ability.extra.bonus }
        end
    end,
}

-- SUIT JOKERS

-- Bloodthirsty Joker


SMODS.Joker {
    key = "bloodthirsty",
    atlas = "SuitJokers",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Swords"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.s_mult,
                localize(card.ability.extra.suit, "suits_singular"),
                colours = {
                    G.C.SUITS[card.ability.extra.suit]
                }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                mult = card.ability.extra.s_mult
            }
        end
    end,
}


-- Drunken Joker

SMODS.Joker {
    key = "drunken",
    atlas = "SuitJokers",
    pos = { x = 1, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Cups"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.s_mult,
                localize(card.ability.extra.suit, "suits_singular"),
                colours = {
                    G.C.SUITS[card.ability.extra.suit]
                }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                mult = card.ability.extra.s_mult
            }
        end
    end,
}


-- Covetous Joker

SMODS.Joker {
    key = "covetous",
    atlas = "SuitJokers",
    pos = { x = 2, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Pentacles"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.s_mult,
                localize(card.ability.extra.suit, "suits_singular"),
                colours = {
                    G.C.SUITS[card.ability.extra.suit]
                }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                mult = card.ability.extra.s_mult
            }
        end
    end,
}


-- Zealous Joker

SMODS.Joker {
    key = "zealous",
    atlas = "SuitJokers",
    pos = { x = 3, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Wands"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.s_mult,
                localize(card.ability.extra.suit, "suits_singular"),
                colours = {
                    G.C.SUITS[card.ability.extra.suit]
                }
            }
        }
    end,

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                mult = card.ability.extra.s_mult
            }
        end
    end,
}

-- Cinnabar

SMODS.Joker {
    key = "cinnabar",
    atlas = "SuitJokers",
    pos = { x = 0, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 7,

    config = {
        extra = {
            numerator = 1,
            denominator = 2,
            xmult = 1.5,
            suit = "vegasstuff_Swords"
        }
    },

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit)
            and SMODS.pseudorandom_probability(
                card,
                "vegasstuff_cinnabar",
                card.ability.extra.numerator,
                card.ability.extra.denominator
            ) then

            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}


-- Aquamarine

SMODS.Joker {
    key = "aquamarine",
    atlas = "SuitJokers",
    pos = { x = 1, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 7,

    config = {
        extra = {
            chips = 50,
            suit = "vegasstuff_Cups"
        }
    },

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}


-- Sunstone

SMODS.Joker {
    key = "sunstone",
    atlas = "SuitJokers",
    pos = { x = 2, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 7,

    config = {
        extra = {
            dollars = 1,
            suit = "vegasstuff_Pentacles"
        }
    },

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                dollars = card.ability.extra.dollars
            }
        end
    end,
}


-- Amethyst

SMODS.Joker {
    key = "amethyst",
    atlas = "SuitJokers",
    pos = { x = 3, y = 1 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    cost = 7,

    config = {
        extra = {
            mult = 7,
            suit = "vegasstuff_Wands"
        }
    },

    calculate = function(self, card, context)
        if context.individual
            and context.cardarea == G.play
            and context.other_card:is_suit(card.ability.extra.suit) then

            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}

-- Pesterchum Chat Client

SMODS.Joker {
    key = "pesterchum",
    atlas = "MiscJokers",
    pos = { x = 0, y = 0 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = {
        extra = {
            xchips = 1.20
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.xchips
            }
        }
    end,

    calculate = function(self, card, context)
        if context.other_joker then
            local name = localize({
                type = "name_text",
                set = "Joker",
                key = context.other_joker.config.center.key
            })

            if name and name:find("%f[%w]Joker%f[%W]") then
                return {
                    xchips = card.ability.extra.xchips
                }
            end
        end
    end,

}

--[[
There's a certain size comin' through your eyes
Maybe just this once we can start a year off right
'Cause I for one am hopin' for one more try
Even if it's hard to pass the time

That night it rained and I held you tight
You kept pourin' more wine just to ease my mind
Then you said you were just like a bird in a cage
Morning came and we watched the rainbow fade

I love you now as I loved you then
But as time goes by I loosen my ties
Still I'm hopin' for one more try
Another chance to taste the rainbow wine
]]

local RAINBOW_DRINKER_SUITS = {
    vegasstuff_Swords = "Spades",
    vegasstuff_Cups = "Hearts",
    vegasstuff_Wands = "Clubs",
    vegasstuff_Pentacles = "Diamonds",
}

SMODS.Joker {
    key = "rainbow_drinker",
    blueprint_compat = true,
    perishable_compat = false,
    rarity = 2,
    cost = 7,

    atlas = "MiscJokers",
    pos = { x = 0, y = 0 },

    config = {
        extra = {
            Xmult_gain = 0.1,
            Xmult = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.Xmult_gain,
                card.ability.extra.Xmult
            }
        }
    end,

calculate = function(self, card, context)
    if context.before and not context.blueprint then
        local drank = {}

        for _, scored_card in ipairs(context.scoring_hand) do
            if not scored_card.debuff
                and not scored_card.rainbow_drank then

                local enhancement = scored_card.config
                    and scored_card.config.center

                local any_suit_enhancement =
                    enhancement
                    and enhancement.set == "Enhanced"
                    and enhancement.any_suit

                local normal_suit =
                    scored_card.base
                    and RAINBOW_DRINKER_SUITS[scored_card.base.suit]

                -- Wild / any-suit Enhancements are consumed first.
                -- The card's base suit is left completely untouched.
                if any_suit_enhancement then
                    drank[#drank + 1] = scored_card
                    scored_card.rainbow_drank = true

                    scored_card:set_ability('c_base', nil, true)

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            scored_card.rainbow_drank = nil
                            return true
                        end
                    }))

                -- Otherwise, consume a Tarot suit normally.
                elseif normal_suit then
                    drank[#drank + 1] = scored_card
                    scored_card.rainbow_drank = true

                    SMODS.change_base(scored_card, normal_suit)

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            scored_card.rainbow_drank = nil
                            return true
                        end
                    }))
                end
            end
        end

        if #drank > 0 then
            card.ability.extra.Xmult =
                card.ability.extra.Xmult
                + card.ability.extra.Xmult_gain * #drank

            return {
                message = localize {
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { card.ability.extra.Xmult }
                },
                colour = G.C.MULT
            }
        end
    end

    if context.joker_main then
        return {
            xmult = card.ability.extra.Xmult
        }
    end
end,
}