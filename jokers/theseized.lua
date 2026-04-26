local ALLOWED_SOURCES = {
    rif = true,
    rta = true,
    sou = true,
    uta = true,
    wra = true
}

SMODS.Joker {
    key = "theseized",
    loc_txt = {
        ['name'] = 'The Seized',
        ['text'] = {
            [1] = '{C:inactive}No effect yet{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
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
