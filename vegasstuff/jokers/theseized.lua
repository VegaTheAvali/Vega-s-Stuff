
SMODS.Joker{ --The Seized
    key = "theseized",
    config = {
        extra = {
            Spec_count = 0,
            Spec_final = 5
        }
    },
    loc_txt = {
        ['name'] = 'The Seized',
        ['text'] = {
            [1] = '{s:3}placeholder{}'
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
    dependencies = {"Cryptid","Polterworx"},
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    soul_pos = {
        x = 3,
        y = 0
    },
    in_pool = function(self, args)
        return (
            not args 
            or args.source ~= 'sho' and args.source ~= 'buf' and args.source ~= 'jud' 
            or args.source == 'rif' or args.source == 'rta' or args.source == 'sou' or args.source == 'uta' or args.source == 'wra'
        )
        and true
    end,
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.Spec_count, card.ability.extra.Spec_final}}
    end
}