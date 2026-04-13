-- Anaphase Enhancement
-- Vega's Stuff
-- After this card is played 3 times, duplicate it without the enhancement

SMODS.Enhancement{
    key = "anaphase",
    atlas = "Anaphase",
    pos = {x = 0, y = 0},

    config = {
        extra = {
            threshold = 3
        }
    },

    loc_txt = {
        name = "Anaphase",
        text = {
            "After this card is played",
            "{C:attention}#2#{} times,",
            "create a copy of it",
            "without this enhancement",
            "{C:inactive}(#1#/#2#)"
        }
    },

    -- Tooltip counter
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.anaphase_plays or 0,
                card.ability.extra.threshold
            }
        }
    end,

    calculate = function(self, card, context)

        -- Runs when cards are about to score
        if context.before and context.cardarea == G.play then

            -- Check if THIS card is one of the played cards
            for _, played_card in ipairs(context.full_hand) do
                if played_card == card then

                    -- Initialize counter
                    card.ability.anaphase_plays = card.ability.anaphase_plays or 0

                    -- Increase counter
                    card.ability.anaphase_plays = card.ability.anaphase_plays + 1

                    -- Trigger duplication
                    if card.ability.anaphase_plays >= card.ability.extra.threshold then
                        card.ability.anaphase_plays = 0

                        G.E_MANAGER:add_event(Event({
                            func = function()

                                local copy = copy_card(card)

                                if copy then
                                    -- Remove enhancement
                                    copy:set_ability(nil)

                                    -- Add card to deck
                                    G.deck:emplace(copy)

                                    copy:start_materialize()
                                end

                                return true
                            end
                        }))

                        return {
                            message = "Divide!",
                            colour = G.C.PURPLE
                        }
                    end

                end
            end
        end
    end
}