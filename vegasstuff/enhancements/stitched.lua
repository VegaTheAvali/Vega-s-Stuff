-- STITCHED ENHANCEMENT (Advanced Version)
-- Compatible with SMODS and designed to play nicely with Joker Forge style retrigger systems.
-- This file is heavily commented so you can understand what each part does.

-- ============================================================
-- BEHAVIOR SUMMARY
-- ============================================================
-- 1. When the card scores, it gives 4x its base chip value
--    Example values:
--      Ace  (11) -> 44 chips
--      Ten  (10) -> 40 chips
--      Three (3) -> 12 chips
--
-- 2. If TWO OR MORE Stitched cards are played in the scoring hand:
--      • Each Stitched card retriggers once
--
-- 3. When the retrigger condition is active:
--      • The card shakes slightly so the player knows it will retrigger
--
-- 4. Uses standard SMODS return values so it remains compatible with
--    Joker Forge retrigger interactions.

SMODS.Enhancement{
    key = "stitched",            -- Internal ID used by other scripts
    name = "Stitched",           -- Name displayed in game
    atlas = "Stitched",          -- Atlas name (must match your texture atlas file)
    pos = {x = 0, y = 0},        -- Position of sprite inside atlas grid

    config = {
        chip_multiplier = 4      -- Multiplier applied to base chip value
    },

    ------------------------------------------------------------
    -- loc_vars
    -- Allows dynamic numbers to appear in the card description
    ------------------------------------------------------------
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.chip_multiplier
            }
        }
    end,

    ------------------------------------------------------------
    -- loc_txt
    -- The text displayed on the enhancement tooltip
    ------------------------------------------------------------
    loc_txt = {
        name = "Stitched",
        text = {
            "Gives #1#x the",
            "card's base",
            "{C:blue}chip{} value",
            " ",
            "If {C:attention}2+{} Stitched",
            "cards are played,",
            "retrigger once"
        }
    },

    ------------------------------------------------------------
    -- calculate()
    -- This function runs during scoring and determines what the
    -- enhancement actually does.
    ------------------------------------------------------------
    calculate = function(self, card, context)

        --------------------------------------------------------
        -- Only run this logic when a card is being scored
        --------------------------------------------------------
        if context.cardarea == G.play and context.main_scoring then

            ----------------------------------------------------
            -- PART 1: Calculate the chip bonus
            -- card.base.nominal contains the base chip value
            -- (Ace=11, King=10, etc)
            ----------------------------------------------------
            local base_chips = card.base.nominal or 0
            local total_chips = base_chips * self.config.chip_multiplier

            ----------------------------------------------------
            -- PART 2: Count how many Stitched cards were played
            ----------------------------------------------------
            local stitched_count = 0

            for i = 1, #context.scoring_hand do
                local c = context.scoring_hand[i]

                if SMODS.has_enhancement(c, "stitched") then
                    stitched_count = stitched_count + 1
                end
            end

            ----------------------------------------------------
            -- PART 3: Determine if retrigger should activate
            -- Option A: only if TWO OR MORE stitched cards
            ----------------------------------------------------
            local retrigger_active = stitched_count >= 2

            ----------------------------------------------------
            -- PART 4: Visual feedback (card shakes slightly)
            -- This helps the player see when retrigger will occur
            ----------------------------------------------------
            if retrigger_active and card and card.juice_up then
                card:juice_up(0.4, 0.4)
            end

            ----------------------------------------------------
            -- PART 5: Return scoring result
            -- "retrigger = true" allows Joker Forge systems to
            -- detect and interact with the retrigger normally
            ----------------------------------------------------
            return {
                chips = total_chips,
                retrigger = retrigger_active
            }
        end
    end
}
