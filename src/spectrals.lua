SMODS.Consumable {
    key = "cwypid",
    set = "Spectral",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    
    cost = 4,
    unlocked = true,
    discovered = true,
    hidden = false,
    atlas = "lmfao",
    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local selected_card = G.hand.highlighted and G.hand.highlighted[1]
        local miniscule = G.P_CENTERS.m_vegasstuff_miniscule
        if not (selected_card and miniscule) then
            return
        end

        for i = 1, 2 do
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.15 * i,
                func = function()
                    G.playing_card = (G.playing_card or 0) + 1
                    local copy = copy_card(selected_card, nil, nil, G.playing_card)

                    copy:set_ability(miniscule)
                    if copy.children and copy.children.center and G.P_CENTERS.c_base then
                        copy.children.center.atlas = G.ASSET_ATLAS.centers
                        copy.children.center:set_sprite_pos(G.P_CENTERS.c_base.pos)
                    end
                    copy:add_to_deck()
                    table.insert(G.playing_cards, copy)
                    G.hand:emplace(copy)
                    copy:start_materialize()
                    playing_card_joker_effects({ copy })
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.45,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
    end,
}

SMODS.Consumable {
    key = "croptid",
    set = "geomancy",
    pos = { x = 6, y = 0 },
    
    cost = 0,
    unlocked = true,
    discovered = true,
    hidden = false,
    no_collection = true,
    atlas = "lmfao",
    in_pool = function(self, args)
        return false
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card, area, copier)
        ease_dollars(2)
    end,
}
