local ASTRO_CHOICES_SMALL_BIG = 3
local ASTRO_CHOICES_BOSS = 5

local function astro_is_active()
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.vegasstuff_solar_deck
end

SMODS.Tag({
    key = "astro",
    atlas = "vegasstuff_tags",
    pos = { x = 1, y = 0 },
    discovered = true,
    config = { type = "new_blind_choice" },
    in_pool = function(self, args)
        return false
    end,
    set_ability = function(self, tag)
        tag.hide_ability = false
    end,
    loc_txt = {
        name = "Astro Tag",
        text = {
            [1] = "Redeem to open a free {C:purple}Astro Pack{}",
            [2] = "{C:attention}Small/Big{} grants normal, {C:red}Boss/Champion{} grants jumbo"
        }
    },
    apply = function(self, tag, context)
        if context.type ~= "new_blind_choice" or not astro_is_active() then
            return
        end

        local choices = tonumber(G.GAME.vegasstuff_solar_pending_choices) or ASTRO_CHOICES_SMALL_BIG
        local key = choices >= ASTRO_CHOICES_BOSS and "p_vegasstuff_jumbo_geomancy_pack" or "p_vegasstuff_geomancy_pack"
        local lock = tag.ID
        G.CONTROLLER.locks[lock] = true

        tag:yep("+", G.C.YELLOW, function()
            local card = Card(
                G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
                G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
                G.CARD_W * 1.27,
                G.CARD_H * 1.27,
                G.P_CARDS.empty,
                G.P_CENTERS[key],
                { bypass_discovery_center = true, bypass_discovery_ui = true }
            )
            card.cost = 0
            card.from_tag = true
            G.FUNCS.use_card({ config = { ref_table = card } })
            card:start_materialize()
            G.GAME.vegasstuff_solar_pending_choices = nil
            G.CONTROLLER.locks[lock] = nil
            return true
        end)

        tag.triggered = true
        return true
    end
})
