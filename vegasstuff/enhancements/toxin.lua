SMODS.Enhancement {
    key = "toxin",
    pos = {x = 0, y = 0},

    config = {
        extra = {
            plays = 5,
            xmult = 5
        }
    },

    loc_txt = {
        name = "Toxin",
        text = {
            [1] = "Gives {X:red,C:white}X#1#{} Mult",
            [2] = "Destroyed after",
            [3] = "{C:attention}#2#{} plays"
        }
    },

    atlas = "Toxin",
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.extra.xmult,
                card.ability.extra.plays or self.config.extra.plays
            }
        }
    end,

    calculate = function(self, card, context)

        if context.main_scoring and context.cardarea == G.play then
            card.ability.extra.plays = (card.ability.extra.plays or self.config.extra.plays) - 1

            if card.ability.extra.plays <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
            end

            return {
                xmult = self.config.extra.xmult
            }
        end
    end
}