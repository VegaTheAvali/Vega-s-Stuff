-- Midas Enhancement
-- Vega's Stuff
-- Gives $5 when scored and retriggers for each other Midas card played

SMODS.Enhancement{
    key = "midas",
    atlas = "Midas",
    pos = {x = 0, y = 0},

    config = {
        extra = {
            dollars = 5
        }
    },

    loc_txt = {
        name = "{C:enhanced}Midas{}",
        text = {
            "Gain {C:money}$#1#{} when scored",
            "Retriggers for each",
            "other {C:enhanced}Midas{} card played"
        }
    },

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,

    calculate = function(self, card, context)

        -- Trigger when cards are scored
        if context.main_scoring and context.cardarea == G.play then

            -- Count Midas cards in played hand
            local midas_count = 0

            for _, c in ipairs(context.full_hand) do
                if c.config.center.key == "m_vegasstuff_midas" then
                    midas_count = midas_count + 1
                end
            end

            return {
                dollars = card.ability.extra.dollars,
                retrigger = midas_count - 1
            }
        end
    end
}