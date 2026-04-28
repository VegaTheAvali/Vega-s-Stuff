SMODS.Tag({
    key = "boric",
    atlas = "vegasstuff_tags",
    pos = { x = 2, y = 0 },
    discovered = true,
    config = { type = "store_joker_modify", edition = "vegasstuff_boric" },
    loc_txt = {
        name = "Boric Tag",
        text = {
            [1] = "Next {C:attention}base edition{} shop",
            [2] = "{C:attention}Joker{} is free and becomes",
            [3] = "{C:dark_edition}Boric{}"
        }
    },
    loc_vars = function(self, info_queue, tag)
        if G and G.P_CENTERS and G.P_CENTERS.e_vegasstuff_boric then
            info_queue[#info_queue + 1] = G.P_CENTERS.e_vegasstuff_boric
        end
    end,
    apply = function(self, tag, context)
        if context.type ~= "store_joker_modify" then
            return
        end

        local card = context.card
        if not (card and card.ability and card.ability.set == "Joker") then
            return
        end

        if Cryptid and Cryptid.forced_edition and Cryptid.forced_edition() then
            tag:nope()
            return
        end

        if card.edition or card.temp_edition then
            return
        end

        local lock = tag.ID
        G.CONTROLLER.locks[lock] = true
        card.temp_edition = true

        tag:yep("+", G.C.DARK_EDITION, function()
            card:set_edition("e_vegasstuff_boric", true)
            card.ability.couponed = true
            card:set_cost()
            card.temp_edition = nil
            G.CONTROLLER.locks[lock] = nil
            return true
        end)

        tag.triggered = true
        return true
    end
})
