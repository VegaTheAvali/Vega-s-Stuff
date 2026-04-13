SMODS.Enhancement {
    key = 'duality',
    pos = { x = 0, y = 0 },

    loc_txt = {
        name = 'Duality',
        text = {
            [1] = 'Decrease Blind size by',
            [2] = '{C:blue}#1#%{} when scored'
        }
    },

    atlas = 'Duality',
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
        if not card then return {vars = {0}} end

        local id = card:get_id()
        local chip_val = 0

        if id == 14 then
            chip_val = 11
        elseif id >= 10 then
            chip_val = 10
        else
            chip_val = id
        end

        return {vars = {chip_val / 2}}
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then

            local id = card:get_id()
            local chip_val = 0

            if id == 14 then
                chip_val = 11
            elseif id >= 10 then
                chip_val = 10
            else
                chip_val = id
            end

            local reduction = chip_val / 2

            if G.GAME.blind and G.GAME.blind.chips then
                local new_blind = G.GAME.blind.chips * (1 - reduction/100)

                -- safety floor
                if new_blind < 1 then
                    new_blind = 1
                end

                G.GAME.blind.chips = new_blind
            end

            return {
                message = "-"..reduction.."%",
                colour = G.C.BLUE
            }
        end
    end
}