-- Tapered Enhancement
-- Vega's Stuff
-- Effect:
-- When ONE card with Tapered is played by itself,
-- give every card held in hand a random seal.
-- Cards that already have a seal will NOT be changed.

SMODS.Enhancement{
    key = "tapered", -- internal ID (creates center key m_tapered)
    atlas = "Tapered", -- atlas this enhancement uses
    pos = {x = 0, y = 0}, -- position in the atlas (change if needed)

    -- Configuration table (not strictly needed here but useful later)
    config = {},

    -- Localization text shown in game
    loc_txt = {
        name = "Tapered",
        text = {
            "If {C:attention}one{} Tapered card",
            "is played {C:attention}alone{},",
            "give all cards in hand",
            "a {C:attention}random Seal{}",
            "{C:inactive}(Does not overwrite seals){}"
        }
    },

    --------------------------------------------------
    -- MAIN EFFECT
    -- Runs during card scoring
    --------------------------------------------------
    calculate = function(self, card, context)

        -- Trigger when cards are scored
        if context.cardarea == G.play and context.main_scoring then

            -- Check if only ONE card was played
            if #context.full_hand == 1 then

                local played_card = context.full_hand[1]

                -- Check if the played card has the Tapered enhancement
                if played_card.config.center.key == "m_vegasstuff_tapered" then

                    -- Loop through cards currently held in hand
                    for _, hand_card in ipairs(G.hand.cards) do

                        -- Only apply seal if the card doesn't already have one
                        if not hand_card.seal then

                            -- List of possible seals
                            local seals = {
                                "Gold",
                                "Red",
                                "Blue",
                                "Purple"
                            }

                            -- Choose a random seal
                            local chosen_seal = pseudorandom_element(seals, pseudoseed("tapered"))

                            -- Apply the seal
                            hand_card:set_seal(chosen_seal, true)

                        end
                    end

                    -- Visual feedback text
                    return {
                        message = "Tapered!",
                        colour = G.C.ATTENTION
                    }

                end
            end
        end
    end
}