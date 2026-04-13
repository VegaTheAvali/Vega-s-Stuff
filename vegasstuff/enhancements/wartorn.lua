SMODS.Enhancement {
    key = 'wartorn',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            mult0 = 11,
            chips0 = -11,
            mult = 10,
            chips = -10,
            mult2 = 10,
            chips2 = -10,
            mult3 = 10,
            chips3 = -10,
            mult4 = 10,
            chips4 = -10,
            mult5 = 9,
            chips5 = -9,
            mult6 = 8,
            chips6 = -8,
            mult7 = 7,
            chips7 = -7,
            mult8 = 6,
            chips8 = -6,
            mult9 = 5,
            chips9 = -5,
            mult10 = 4,
            chips10 = -4,
            mult11 = 3,
            chips11 = -3,
            mult12 = 2,
            chips12 = -2
        }
    },
    loc_txt = {
        name = 'War Torn',
        text = {
            [1] = 'Gives base value in {C:red}Mult{} instead of {C:blue}Chips{}'
        }
    },
    atlas = 'WarTorn',
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
        return {vars = {localize((G.GAME.current_round.Ace_card or {}).rank or 'Ace', 'ranks')}}
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local id = card:get_id()
            local val = 0

            if id == 14 then
                val = self.config.extra.mult0
            elseif id == 13 then
                val = self.config.extra.mult
            elseif id == 12 then
                val = self.config.extra.mult2
            elseif id == 11 then
                val = self.config.extra.mult3
            elseif id == 10 then
                val = self.config.extra.mult4
            elseif id == 9 then
                val = self.config.extra.mult5
            elseif id == 8 then
                val = self.config.extra.mult6
            elseif id == 7 then
                val = self.config.extra.mult7
            elseif id == 6 then
                val = self.config.extra.mult8
            elseif id == 5 then
                val = self.config.extra.mult9
            elseif id == 4 then
                val = self.config.extra.mult10
            elseif id == 3 then
                val = self.config.extra.mult11
            elseif id == 2 then
                val = self.config.extra.mult12
            end

            return {
                mult = val,
                extra = {
                    chips = -val,
                    colour = G.C.CHIPS
                }
            }
        end
    end
}