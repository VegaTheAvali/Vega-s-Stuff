local ASTRO_CHOICES_SMALL_BIG = 3
local ASTRO_CHOICES_BOSS = 5
local ASTRO_SLEEVE_WEIGHT_MULT = 4

local function astro_is_active()
    return (Vegasstuff and Vegasstuff.is_solar_deck and Vegasstuff.is_solar_deck())
        or (Vegasstuff and Vegasstuff.solar_sleeve_astro_tags_active and Vegasstuff.solar_sleeve_astro_tags_active())
end

local function astro_choices_from_tag(tag)
    local pending_choices = G and G.GAME and tonumber(G.GAME.vegasstuff_solar_pending_choices) or nil
    if pending_choices then
        return pending_choices
    end

    local blind_type = tag and tag.ability and tag.ability.blind_type
    if blind_type == "Boss" then
        return ASTRO_CHOICES_BOSS
    end
    return ASTRO_CHOICES_SMALL_BIG
end

SMODS.Tag({
    key = "astro",
    atlas = "vegasstuff_tags",
    pos = { x = 1, y = 0 },
    discovered = true,
    weight = 10,
    config = { type = "new_blind_choice" },
    in_pool = function(self, args)
        return Vegasstuff and Vegasstuff.solar_sleeve_astro_tags_active and Vegasstuff.solar_sleeve_astro_tags_active()
    end,
    get_weight = function(self, weight, args)
        if Vegasstuff and Vegasstuff.solar_sleeve_astro_tags_active and Vegasstuff.solar_sleeve_astro_tags_active() then
            return (weight or 10) * ASTRO_SLEEVE_WEIGHT_MULT
        end
        return weight or 10
    end,
    set_ability = function(self, tag)
        tag.hide_ability = false
    end,
    loc_txt = {
        name = "Astro Tag",
        text = {
            [1] = "Open a free {C:vegasstuff_geomancy}Astro Pack{}",
            [2] = "{C:attention}Boss/Champion Blinds{}",
            [3] = "open a {C:attention}Jumbo Pack{} instead"
        }
    },
    apply = function(self, tag, context)
        if context.type ~= "new_blind_choice" or not astro_is_active() then
            return
        end

        local choices = astro_choices_from_tag(tag)
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
