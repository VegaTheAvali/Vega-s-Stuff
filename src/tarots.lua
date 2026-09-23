-- Alcohol
SMODS.Consumable {
    key = 'alcohol',
    set = 'Tarot',

    atlas = 'vega_tarot',
    pos = { x = 0, y = 0 },

    config = {
        max_highlighted = 3,
        suit_conv = 'vegasstuff_Cups'
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.max_highlighted,
                localize(card.ability.suit_conv, 'suits_plural'),
                colours = {
                    G.C.SUITS[card.ability.suit_conv]
                }
            }
        }
    end,
}


-- Magic
SMODS.Consumable {
    key = 'magic',
    set = 'Tarot',

    atlas = 'vega_tarot',
    pos = { x = 1, y = 0 },

    config = {
        max_highlighted = 3,
        suit_conv = 'vegasstuff_Wands'
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.max_highlighted,
                localize(card.ability.suit_conv, 'suits_plural'),
                colours = {
                    G.C.SUITS[card.ability.suit_conv]
                }
            }
        }
    end,
}


-- Riches
SMODS.Consumable {
    key = 'riches',
    set = 'Tarot',

    atlas = 'vega_tarot',
    pos = { x = 2, y = 0 },

    config = {
        max_highlighted = 3,
        suit_conv = 'vegasstuff_Pentacles'
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.max_highlighted,
                localize(card.ability.suit_conv, 'suits_plural'),
                colours = {
                    G.C.SUITS[card.ability.suit_conv]
                }
            }
        }
    end,
}


-- Dummy
SMODS.Consumable {
    key = 'dummy',
    set = 'Tarot',

    atlas = 'vega_tarot',
    pos = { x = 3, y = 0 },

    config = {
        max_highlighted = 3,
        suit_conv = 'vegasstuff_Swords'
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.max_highlighted,
                localize(card.ability.suit_conv, 'suits_plural'),
                colours = {
                    G.C.SUITS[card.ability.suit_conv]
                }
            }
        }
    end,
}