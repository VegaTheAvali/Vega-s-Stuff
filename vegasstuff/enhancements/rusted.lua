-- RUSTED ENHANCEMENT
-- This file defines a custom enhancement for Balatro mods using SMODS.
-- It is written to be compatible with Joker Forge style retrigger systems.

-- BEHAVIOR SUMMARY
-- +100 Chips when the card is scored
-- +5 Mult when the card is HELD in hand (always, regardless of other Rusted cards)
-- If NO Rusted cards were played in the scoring hand, the held card RETRIGGERS once
-- When the retrigger condition is active, the card will SHAKE slightly as a visual cue

SMODS.Enhancement{
    key = "rusted",                 -- internal id
    name = "Rusted",                -- display name
    atlas = "Rusted",               -- texture atlas name (must exist in your assets)
    pos = {x = 0, y = 0},           -- sprite position in the atlas

    config = {
        chips = 100,                -- chips given when the card scores
        held_mult = 5               -- mult given while held in hand
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.chips,
                self.config.held_mult
            }
        }
    end,

    loc_txt = {
        name = "Rusted",
        text = {
            "{C:blue}+#1# Chips{}",
            "Held in hand: {C:red}+#2# Mult{}",
            "Retrigger once if",
            "no {C:enhanced}Rusted{} cards",
            "were played"
        }
    },

    -- This function runs during scoring
    calculate = function(self, card, context)

        ------------------------------------------------------------------
        -- PART 1: GIVE +100 CHIPS WHEN THE CARD IS PLAYED
        ------------------------------------------------------------------
        if context.cardarea == G.play and context.main_scoring then
            return {
                chips = self.config.chips
            }
        end


        ------------------------------------------------------------------
        -- PART 2: +5 MULT WHEN HELD IN HAND
        ------------------------------------------------------------------
        if context.cardarea == G.hand and context.main_scoring then

            local rusted_in_played = false

            -- Check all cards in the scoring hand
            for i = 1, #context.scoring_hand do
                local c = context.scoring_hand[i]

                if SMODS.has_enhancement(c, "rusted") then
                    rusted_in_played = true
                    break
                end
            end

            -- Base held bonus
            local result = {
                mult = self.config.held_mult
            }

            ------------------------------------------------------------------
            -- PART 3: RETRIGGER CONDITION
            -- If no Rusted cards were played in the scoring hand
            ------------------------------------------------------------------
            if not rusted_in_played then

                -- Make the card visually shake to show retrigger is active
                if card and card.juice_up then
                    card:juice_up(0.4, 0.4)
                end

                -- Tell Balatro to retrigger the card once
                result.retrigger = true
            end

            return result
        end
    end
}
