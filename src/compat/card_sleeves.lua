if not (CardSleeves and CardSleeves.Sleeve) then
    return
end

local SOLAR_DECK_KEY = "b_vegasstuff_solar_deck"
local ASTRO_TAG_EXTRA_COPIES = 3

SMODS.Atlas({
    key = "SolarSleeve",
    path = "Solar Sleeve.png",
    px = 73,
    py = 97
})

local function current_deck_is_solar(self)
    local get_deck_key = self and self.get_current_deck_key or CardSleeves.Sleeve.get_current_deck_key
    return get_deck_key and get_deck_key() == SOLAR_DECK_KEY
end

if not _G.vegasstuff_solar_sleeve_tag_pool_hooked and type(get_current_pool) == "function" then
    _G.vegasstuff_solar_sleeve_tag_pool_hooked = true
    local get_current_pool_ref = get_current_pool
    function get_current_pool(_type, _rarity, _legendary, _append)
        local pool, pool_key = get_current_pool_ref(_type, _rarity, _legendary, _append)

        if _type == "Tag"
            and Vegasstuff
            and Vegasstuff.solar_sleeve_astro_tags_active
            and Vegasstuff.solar_sleeve_astro_tags_active()
            and G
            and G.P_TAGS
            and G.P_TAGS.tag_vegasstuff_astro
            and not (G.GAME and G.GAME.banned_keys and G.GAME.banned_keys.tag_vegasstuff_astro) then
            for i = 1, ASTRO_TAG_EXTRA_COPIES do
                pool[#pool + 1] = "tag_vegasstuff_astro"
            end
            pool_key = tostring(pool_key or "Tag") .. "_vegasstuff_solar_sleeve"
        end

        return pool, pool_key
    end
end

CardSleeves.Sleeve({
    key = "solar",
    name = "Solar Sleeve",
    atlas = "SolarSleeve",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,

    loc_vars = function(self)
        if current_deck_is_solar(self) then
            return { key = self.key .. "_alt", vars = { 2 } }
        end
        return { vars = { ASTRO_TAG_EXTRA_COPIES + 1 } }
    end,
    apply = function(self, sleeve)
        G.GAME.vegasstuff_solar_sleeve = true
        G.GAME.vegasstuff_solar_sleeve_mode = current_deck_is_solar(self) and "geomancy" or "astro_tags"
    end
})
