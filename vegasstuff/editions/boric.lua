SMODS.Edition {
    key = 'boric',

    -- You can keep 'foil' or swap later for a custom shader
    shader = false,

    in_shop = true,
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,

    loc_txt = {
        name = 'Boric',
        text = {
            [1] = 'Cards with Boric give {C:attention}+1{} selection limit'
        }
    },

    unlocked = true,
    discovered = true,
    no_collection = false,

    get_weight = function(self)
        return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
    end,
}

-- Gameplay effect hook
SMODS.Joker {
    key = "boric_helper",

    config = { extra = { bonus = 1 } },

    loc_txt = {
        name = "Boric Helper",
        text = {
            "Handles Boric selection limit bonus"
        }
    },

    -- This hook tries to safely apply the effect
    calculate = function(self, card, context)
        if not G or not G.GAME then return end

        -- Check if any card in hand has Boric edition
        local boric_count = 0

        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if c.edition and c.edition.key == 'e_boric' then
                    boric_count = boric_count + 1
                end
            end
        end

        -- Apply selection limit bonus if at least one exists
        if boric_count > 0 and context and context.modify_selection_limit then
            context.modify_selection_limit = context.modify_selection_limit + boric_count
        end
    end
}