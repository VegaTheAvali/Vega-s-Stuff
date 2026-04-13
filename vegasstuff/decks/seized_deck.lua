
SMODS.Back {
    key = 'seized_deck',
    pos = { x = 0, y = 0 },
    config = {
    },
    loc_txt = {
        name = 'Seized deck',
        text = {
            [1] = 'A {C:blue}custom{} deck with',
            [2] = '{C:red}unique{} effects.'
        },
    },
    unlocked = true,
    discovered = true,
    no_collection = false,
    atlas = 'CustomDecks',
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                play_sound('timpani')
                if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                    G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                    local new_joker = SMODS.add_card({ set = 'Joker', key = 'j_vegasstuff_vega' })
                    if new_joker then
                        new_joker:add_sticker('eternal', true)
                    end
                    G.GAME.joker_buffer = 0
                end
                return true
            end
        }))
    end
}