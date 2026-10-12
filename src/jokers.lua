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
    discovered = false,
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




local function deck_has_tarot_suit(suit)
    if not (G and G.playing_cards) then
        return false
    end

    for _, playing_card in ipairs(G.playing_cards) do
        local enhancement =
            playing_card.config
            and playing_card.config.center

        local is_any_suit =
            enhancement
            and enhancement.set == "Enhanced"
            and enhancement.any_suit

        if (playing_card.base and playing_card.base.suit == suit)
            or is_any_suit then
            return true
        end
    end

    return false
end

local function deck_has_any_tarot_suit()
    for _, standard_suit in ipairs({ "Spades", "Hearts", "Clubs", "Diamonds" }) do
        local tarot_suit = Vegasstuff.get_suit_equivalent(standard_suit, "tarot")
        if deck_has_tarot_suit(tarot_suit) then
            return true
        end
    end

    return false
end

local function add_tarot_suit_tooltip(info_queue)
    info_queue[#info_queue + 1] = {
        key = "vegasstuff_tarot_suit_equivalents",
        set = "Other",
        vars = {
            colours = {
                G.C.SUITS["vegasstuff_Swords"],
                G.C.SUITS["vegasstuff_Cups"],
                G.C.SUITS["vegasstuff_Wands"],
                G.C.SUITS["vegasstuff_Pentacles"],
            }
        }
    }
end

local function swatched_active()
    if not (G and G.jokers and G.jokers.cards) then
        return false
    end

    for _, joker in ipairs(G.jokers.cards) do
        if joker.config
            and joker.config.center
            and joker.config.center.key == "j_vegasstuff_swatched"
            and not joker.debuff then
            return true
        end
    end

    return false
end

if not _G.vegasstuff_swatched_is_suit_hooked then
    _G.vegasstuff_swatched_is_suit_hooked = true

    local is_suit_ref = Card.is_suit

    function Card:is_suit(suit, bypass_debuff, flush_calc)
        if is_suit_ref(self, suit, bypass_debuff, flush_calc) then
            return true
        end

        if swatched_active()
            and self.base
            and Vegasstuff.get_suit_equivalent(self.base.suit, "standard") == suit then
            return true
        end

        return false
    end
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
    discovered = false,
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
                            G.hand:change_size(total_gain)
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(total_gain).." Hand Size & Selection", colour = G.C.BLUE})
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

local function register_vega_hand_joker(args)
    SMODS.Joker {
        key = args.key,

        atlas = "HandJokers",
        pos = args.pos,

        rarity = args.rarity,
        cost = args.cost,

        unlocked = not args.locked,
        discovered = false,

        blueprint_compat = true,
        eternal_compat = true,
        perishable_compat = true,
        demicolon_compat = args.rarity == 1,

        config = {
            extra = {
                value = args.value,
                type = args.hand_type,
                effect = args.effect
            }
        },

        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.extra.value,
                    localize(card.ability.extra.type, "poker_hands")
                }
            }
        end,

        locked_loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    localize(self.config.extra.type, "poker_hands")
                }
            }
        end,

       in_pool = function(self, pool_args)
    local hand =
        G
        and G.GAME
        and G.GAME.hands
        and G.GAME.hands[self.config.extra.type]

    return hand
        and hand.played
        and hand.played > 0
end,

        calculate = function(self, card, context)
            if context.joker_main
                and context.poker_hands
                and context.poker_hands[card.ability.extra.type]
                and next(context.poker_hands[card.ability.extra.type]) then

                return {
                    [card.ability.extra.effect] =
                        card.ability.extra.value
                }
            end
        end,

        check_for_unlock = function(self, unlock_args)
            if not args.locked then
                return false
            end

            local hand =
                G
                and G.GAME
                and G.GAME.hands
                and G.GAME.hands[self.config.extra.type]

            return hand
                and hand.played
                and hand.played > 0
        end,
    }
end

--- Spell
register_vega_hand_joker {
    key = "bewitched",
    hand_type = "vegasstuff_spell",
    pos = { x = 0, y = 0 },
    rarity = 1,
    cost = 4,
    effect = "mult",
    value = 12
}

register_vega_hand_joker {
    key = "enchanted",
    hand_type = "vegasstuff_spell",
    pos = { x = 0, y = 1 },
    rarity = 1,
    cost = 4,
    effect = "chips",
    value = 80
}

register_vega_hand_joker {
    key = "summoned",
    hand_type = "vegasstuff_spell",
    pos = { x = 0, y = 2 },
    rarity = 3,
    cost = 8,
    effect = "xmult",
    value = 2,
    locked = true
}


-- Mint
register_vega_hand_joker {
    key = "clean",
    hand_type = "vegasstuff_mint",
    pos = { x = 1, y = 0 },
    rarity = 1,
    cost = 4,
    effect = "mult",
    value = 14
}

register_vega_hand_joker {
    key = "fresh",
    hand_type = "vegasstuff_mint",
    pos = { x = 1, y = 1 },
    rarity = 1,
    cost = 4,
    effect = "chips",
    value = 100
}

register_vega_hand_joker {
    key = "refreshed",
    hand_type = "vegasstuff_mint",
    pos = { x = 1, y = 2 },
    rarity = 3,
    cost = 8,
    effect = "xmult",
    value = 2,
    locked = true
}


-- Package
register_vega_hand_joker {
    key = "caught",
    hand_type = "vegasstuff_package",
    pos = { x = 2, y = 0 },
    rarity = 1,
    cost = 4,
    effect = "mult",
    value = 13
}

register_vega_hand_joker {
    key = "captured",
    hand_type = "vegasstuff_package",
    pos = { x = 2, y = 1 },
    rarity = 1,
    cost = 4,
    effect = "chips",
    value = 90
}

register_vega_hand_joker {
    key = "delivered",
    hand_type = "vegasstuff_package",
    pos = { x = 2, y = 2 },
    rarity = 3,
    cost = 8,
    effect = "xmult",
    value = 2,
    locked = true
}


-- Postage
register_vega_hand_joker {
    key = "posted",
    hand_type = "vegasstuff_postage",
    pos = { x = 3, y = 0 },
    rarity = 1,
    cost = 4,
    effect = "mult",
    value = 15
}

register_vega_hand_joker {
    key = "publicized",
    hand_type = "vegasstuff_postage",
    pos = { x = 3, y = 1 },
    rarity = 1,
    cost = 4,
    effect = "chips",
    value = 100
}

register_vega_hand_joker {
    key = "office",
    hand_type = "vegasstuff_postage",
    pos = { x = 3, y = 2 },
    rarity = 3,
    cost = 8,
    effect = "xmult",
    value = 2,
    locked = true
}


-- Cauldron
register_vega_hand_joker {
    key = "spellbound",
    hand_type = "vegasstuff_cauldron",
    pos = { x = 4, y = 0 },
    rarity = 1,
    cost = 4,
    effect = "mult",
    value = 16
}

register_vega_hand_joker {
    key = "hexed",
    hand_type = "vegasstuff_cauldron",
    pos = { x = 4, y = 1 },
    rarity = 1,
    cost = 4,
    effect = "chips",
    value = 120
}

register_vega_hand_joker {
    key = "brewed",
    hand_type = "vegasstuff_cauldron",
    pos = { x = 4, y = 2 },
    rarity = 3,
    cost = 8,
    effect = "xmult",
    value = 2,
    locked = true
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
    discovered = false,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Swords"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Cups"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
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

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
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
    discovered = false,
    cost = 5,

    config = {
        extra = {
            s_mult = 3,
            suit = "vegasstuff_Wands"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
    cost = 7,

    config = {
        extra = {
            numerator = 1,
            denominator = 2,
            xmult = 1.5,
            suit = "vegasstuff_Swords"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
    perishable_compat = true,
    cost = 7,

    config = {
        extra = {
            chips = 50,
            suit = "vegasstuff_Cups"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
    cost = 7,

    config = {
        extra = {
            dollars = 1,
            suit = "vegasstuff_Pentacles"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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
    discovered = false,
    cost = 7,

    config = {
        extra = {
            mult = 7,
            suit = "vegasstuff_Wands"
        }
    },

      in_pool = function(self, args)
        return deck_has_tarot_suit(self.config.extra.suit)
    end,

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

-- Misc Jokers

SMODS.Joker {
    key = "scrapyard",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "vegasstuff_modified_card", set = "Other" }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards then
            local removed = {}
            local modifications = {}
            for _, destroyed_card in ipairs(context.removed) do
                removed[destroyed_card] = true
                if destroyed_card.config.center.set == "Enhanced" then
                    modifications[#modifications + 1] = { type = "enhancement", value = destroyed_card.config.center }
                end
                if destroyed_card.seal then
                    modifications[#modifications + 1] = { type = "seal", value = destroyed_card.seal }
                end
                if destroyed_card.edition then
                    modifications[#modifications + 1] = { type = "edition", value = copy_table(destroyed_card.edition) }
                end
                for _, sticker in ipairs(SMODS.Sticker.obj_buffer) do
                    if destroyed_card.ability[sticker] then
                        modifications[#modifications + 1] = {
                            type = "sticker", key = sticker,
                            value = type(destroyed_card.ability[sticker]) == "table"
                                and copy_table(destroyed_card.ability[sticker]) or destroyed_card.ability[sticker],
                            perish_tally = destroyed_card.ability.perish_tally,
                        }
                    end
                end
            end

            if #modifications == 0 then return end

            local message_card = context.blueprint_card or card
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local transferred = false
                            for _, modification in ipairs(modifications) do
                                local candidates = {}
                                for _, hand_card in ipairs(G.hand.cards) do
                                    if not removed[hand_card] then
                                        if (modification.type == "enhancement" and hand_card.config.center.set ~= "Enhanced")
                                            or (modification.type == "seal" and not hand_card.seal)
                                            or (modification.type == "edition" and not hand_card.edition)
                                            or (modification.type == "sticker" and not hand_card.ability[modification.key]
                                                and SMODS.Stickers[modification.key]:should_apply(hand_card, hand_card.config.center, G.hand, true)) then
                                            candidates[#candidates + 1] = hand_card
                                        end
                                    end
                                end

                                if #candidates > 0 then
                                    local target = pseudorandom_element(candidates, pseudoseed("vegasstuff_scrapyard_" .. (modification.key or modification.type)))
                                    if modification.type == "enhancement" then
                                        target:set_ability(modification.value)
                                    elseif modification.type == "seal" then
                                        target:set_seal(modification.value, true)
                                    elseif modification.type == "edition" then
                                        target:set_edition(copy_table(modification.value), true, true)
                                    else
                                        SMODS.Stickers[modification.key]:apply(target,
                                            type(modification.value) == "table" and copy_table(modification.value) or modification.value)
                                        if modification.key == "perishable" then
                                            target.ability.perish_tally = modification.perish_tally
                                        end
                                    end
                                    target:juice_up()
                                    transferred = true
                                end
                            end
                            if transferred then
                                SMODS.calculate_effect({ message = localize("k_vegasstuff_recycled"), colour = G.C.GREEN }, message_card)
                            end
                            return true
                        end,
                    }))
                    return true
                end,
            }))
            return nil, true
        end
    end,
}

SMODS.Joker {
    key = "geode",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    config = { extra = { balance = 1 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "vegasstuff_modified_card", set = "Other" }
        return { vars = { card.ability.extra.balance } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local modified = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.config.center.set == "Enhanced" or playing_card.seal or playing_card.edition
                    or playing_card.ability.eternal or playing_card.ability.perishable or playing_card.ability.rental then
                    modified = modified + 1
                else
                    for _, sticker in ipairs(SMODS.Sticker.obj_buffer) do
                        if playing_card.ability[sticker] then
                            modified = modified + 1
                            break
                        end
                    end
                end
            end

            if modified > 0 then
                return { vegasstuff_balance_percent = modified * card.ability.extra.balance / 100 }
            end
        end
    end,
}

SMODS.Joker {
    key = "crystal_formation",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 2,
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    config = { extra = { xchips = 1.5, required = 3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = "vegasstuff_modified_card", set = "Other" }
        return { vars = { card.ability.extra.xchips, card.ability.extra.required } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local modified = 0
            for _, playing_card in ipairs(context.scoring_hand) do
                if playing_card.config.center.set == "Enhanced" or playing_card.seal or playing_card.edition
                    or playing_card.ability.eternal or playing_card.ability.perishable or playing_card.ability.rental then
                    modified = modified + 1
                else
                    for _, sticker in ipairs(SMODS.Sticker.obj_buffer) do
                        if playing_card.ability[sticker] then
                            modified = modified + 1
                            break
                        end
                    end
                end
            end

            if modified >= card.ability.extra.required then
                return { xchips = card.ability.extra.xchips }
            end
        end
    end,
}

SMODS.Joker {
    key = "rock_candy",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true, ["vegasstuff_food"] = true },
    config = { extra = { balance = 10, rounds = 3 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.balance, card.ability.extra.rounds } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { vegasstuff_balance_percent = card.ability.extra.balance / 100 }
        end

        if context.end_of_round and context.game_over == false and context.main_eval
            and not context.blueprint and not context.retrigger_joker then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then
                if #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card { set = "geomancy", area = G.consumeables, key_append = "vegasstuff_rock_candy" }
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                            return true
                        end,
                    }))
                end
                SMODS.destroy_cards(card, { pinch_anim = true })
                return { message = localize("k_eaten_ex"), colour = G.C.PURPLE }
            end

            return {
                message = localize { type = "variable", vars = { card.ability.extra.rounds } },
                colour = G.C.FILTER,
            }
        end
    end,
}

SMODS.Joker {
    key = "crystal",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 2,
    cost = 7,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    config = { extra = { sell_value = 2 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_value } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable
            and context.consumeable.ability.set == "geomancy" then
            local candidates = {}
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= card and joker ~= context.blueprint_card then
                    candidates[#candidates + 1] = joker
                end
            end

            if #candidates == 0 then
                return
            end

            local target = pseudorandom_element(candidates, pseudoseed("vegasstuff_crystal"))
            target.ability.extra_value = (target.ability.extra_value or 0)
                + card.ability.extra.sell_value
            target:set_cost()

            return {
                message = localize('k_val_up'),
                message_card = target,
                colour = G.C.MONEY,
            }
        end
    end,
}

SMODS.Joker {
    key = "horoscope",
    atlas = "MiscJokers",
    pos = { x = 0, y = 1 },
    rarity = 1,
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    discovered = false,
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    config = { extra = { chips = 0, chip_gain = 10 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_gain, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint
            and context.consumeable.ability.set == "zodiac" then
            if SMODS.scale_card then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = "chips",
                    scalar_value = "chip_gain",
                    no_message = true,
                })
            else
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
            end

            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.CHIPS,
            }
        end

        if context.joker_main then
            return { chips = card.ability.extra.chips }
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
    discovered = false,

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



SMODS.Joker {
    key = "rainbow_drinker",
    blueprint_compat = true,
    perishable_compat = false,
    rarity = 2,
    cost = 7,

    atlas = "MiscJokers",
    pos = { x = 2, y = 0 },

    config = {
        extra = {
            Xmult_gain = 0.1,
            Xmult = 1
        }
    },

    loc_vars = function(self, info_queue, card)
        add_tarot_suit_tooltip(info_queue)

        return {
            vars = {
                card.ability.extra.Xmult_gain,
                card.ability.extra.Xmult
            }
        }
    end,

    in_pool = function(self, args)
    return deck_has_any_tarot_suit()
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
                    and Vegasstuff.get_suit_equivalent(scored_card.base.suit, "standard")

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

SMODS.Joker {
    key = "swatched",

    rarity = 2,
    cost = 7,

    atlas = "MiscJokers",
    pos = { x = 3, y = 0 },
    discovered = false,
    blueprint_compat = false,

        loc_vars = function(self, info_queue, card)
            add_tarot_suit_tooltip(info_queue)
            return {}
        end,

        in_pool = function(self, args)
    return deck_has_any_tarot_suit()
end,
}

SMODS.Joker {
    key = "lesser_blessed",
    rarity = 2,
    cost = 7,

    atlas = "MiscJokers",
    pos = { x = 4, y = 0 },
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    config = {
        extra = {
            xchips_per_suit = 0.25
        }
    },

    loc_vars = function(self, info_queue, card)
        add_tarot_suit_tooltip(info_queue)

        return {
            vars = {
                card.ability.extra.xchips_per_suit
            }
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand then
            local suit_sets = {}

            for _, scored_card in ipairs(context.scoring_hand) do
                local enhancement =
                    scored_card.config
                    and scored_card.config.center

                local any_suit =
                    enhancement
                    and enhancement.set == "Enhanced"
                    and enhancement.any_suit

                if any_suit then
                    suit_sets.Spades = true
                    suit_sets.Hearts = true
                    suit_sets.Clubs = true
                    suit_sets.Diamonds = true

                elseif scored_card.base and scored_card.base.suit then
                    local suit = scored_card.base.suit
                    local regular_suit =
                        Vegasstuff.get_suit_equivalent(suit, "standard")
                        or suit

                    if regular_suit == "Spades"
                        or regular_suit == "Hearts"
                        or regular_suit == "Clubs"
                        or regular_suit == "Diamonds" then

                        suit_sets[regular_suit] = true
                    end
                end
            end

            local unique_sets = 0

            for _ in pairs(suit_sets) do
                unique_sets = unique_sets + 1
            end

            if unique_sets > 0 then
                return {
                    xchips = 1
                        + card.ability.extra.xchips_per_suit
                        * unique_sets
                }
            end
        end
    end,
}
