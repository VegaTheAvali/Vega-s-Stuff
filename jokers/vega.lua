
SMODS.Joker{ --Vega
    key = "vega",
    config = {
        extra = {
            Spec_count = 0,
            Spec_final = 5,
            play_size0 = 1,
            hand_size0 = 1
        }
    },
    loc_txt = {
        ['name'] = 'Vega',
        ['text'] = {
            [1] = 'After every {C:attention}5{} {C:spectral}Spectral{} cards used',
            [2] = 'increase {C:rare}selection limit{} by {C:attention}1{}',
            [3] = '{C:inactive}[#1#/5]{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
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
        return (
            not args 
            or args.source ~= 'sho' 
            or args.source == 'buf' or args.source == 'jud' or args.source == 'rif' or args.source == 'rta' or args.source == 'sou' or args.source == 'uta' or args.source == 'wra'
        )
        and true
    end,
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.Spec_count, card.ability.extra.Spec_final}}
    end,
    
    calculate = function(self, card, context)
        if context.using_consumeable  then
            if context.consumeable and context.consumeable.ability.set == 'Spectral' then
                return {
                    func = function()
                        card.ability.extra.Spec_count = (card.ability.extra.Spec_count) + 1
                        return true
                    end
                }
            end
        end
        if context.ending_shop  then
            if to_big((card.ability.extra.Spec_count or 0)) >= to_big(5) then
                return {
                    func = function()
                        card.ability.extra.Spec_count = 0
                        return true
                    end,
                    extra = {
                        
                        func = function()
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Selection", colour = G.C.BLUE})
                            
                            SMODS.change_play_limit(1)
                            return true
                        end,
                        colour = G.C.WHITE,
                        extra = {
                            
                            func = function()
                                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(1).." Hand Size", colour = G.C.BLUE})
                                
                                G.hand:change_size(1)
                                return true
                            end,
                            colour = G.C.WHITE
                        }
                    }
                }
            end
        end
    end
}