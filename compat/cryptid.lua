
local function vegasstuff_apply_cryptid_edeck_sprites()
    if not (SMODS.Mods.Cryptid and SMODS.Mods.Cryptid.can_load and Cryptid and Cryptid.edeck_sprites) then
        return
    end

    Cryptid.edeck_sprites.enhancement = Cryptid.edeck_sprites.enhancement or {}
    Cryptid.edeck_sprites.edition = Cryptid.edeck_sprites.edition or {}

    local deck_atlas = "vegasstuff_crypt_decks"
    if G and G.ASSET_ATLAS then
        if G.ASSET_ATLAS["vegasstuff_crypt_decks"] then
            deck_atlas = "vegasstuff_crypt_decks"
        elseif G.ASSET_ATLAS["crypt_decks"] then
            deck_atlas = "crypt_decks"
        end
    end

    Cryptid.edeck_sprites.enhancement.m_vegasstuff_wartorn = {atlas = deck_atlas, pos = {x = 2, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_anaphase = {atlas = deck_atlas, pos = {x = 3, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_dreamy = {atlas = deck_atlas, pos = {x = 4, y = 1}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_duality = {atlas = deck_atlas, pos = {x = 0, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_midas = {atlas = deck_atlas, pos = {x = 5, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_rusted = {atlas = deck_atlas, pos = {x = 3, y = 1}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_toxin = {atlas = deck_atlas, pos = {x = 1, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_scoped = {atlas = deck_atlas, pos = {x = 4, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_tapered = {atlas = deck_atlas, pos = {x = 6, y = 0}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_soggy = {atlas = deck_atlas, pos = {x = 2, y = 1}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_stitched = {atlas = deck_atlas, pos = {x = 0, y = 1}}
    Cryptid.edeck_sprites.enhancement.m_vegasstuff_creased = {atlas = deck_atlas, pos = {x = 1, y = 1}}
    Cryptid.edeck_sprites.edition.vegasstuff_boric = {atlas = deck_atlas, pos = {x = 5, y = 1}}

end

local function vegasstuff_apply_cryptid_tag_sprites()
    if not (SMODS.Mods.Cryptid and SMODS.Mods.Cryptid.can_load and G and G.P_TAGS) then
        return
    end

    local shiny_tags = {
        "tag_vegasstuff_astro",
        "tag_vegasstuff_zodiac",
        "tag_vegasstuff_boric"
    }

    for _, key in ipairs(shiny_tags) do
        local tag = G.P_TAGS[key]
        if tag then
            tag.shiny_atlas = "vegasstuff_shinytags"
        end
    end

    if SMODS.Tags then
        for _, key in ipairs(shiny_tags) do
            local tag = SMODS.Tags[key]
            if tag then
                tag.shiny_atlas = "vegasstuff_shinytags"
            end
        end
    end
end

local function vegasstuff_hook_cryptid_shiny_tags()
    if _G.vegasstuff_cryptid_shiny_tag_hooked
        or not (SMODS.Mods.Cryptid and SMODS.Mods.Cryptid.can_load)
        or not (Tag and Tag.generate_UI and Tag.set_ability) then
        return
    end

    _G.vegasstuff_cryptid_shiny_tag_hooked = true
    local set_ability_ref = Tag.set_ability
    local generate_ui_ref = Tag.generate_UI
    local unpack_fn = table.unpack or unpack

    function Tag:set_ability(...)
        local results = { set_ability_ref(self, ...) }

        local tag_center = G and G.P_TAGS and self and self.key and G.P_TAGS[self.key]
        if tag_center and tag_center.shiny_atlas and self.ability and self.ability.shiny == nil and not self.ability.blind_type then
            self.ability.shiny = Cryptid and Cryptid.is_shiny and Cryptid.is_shiny() or nil
        end

        return unpack_fn(results)
    end

    function Tag:generate_UI(...)
        local tag_center = G and G.P_TAGS and self and self.key and G.P_TAGS[self.key]
        local use_shiny_atlas = tag_center and self.ability and self.ability.shiny and tag_center.shiny_atlas
        local base_atlas = nil

        if use_shiny_atlas then
            base_atlas = tag_center.atlas
            tag_center.atlas = tag_center.shiny_atlas
        end

        local results = { generate_ui_ref(self, ...) }

        if use_shiny_atlas then
            tag_center.atlas = base_atlas
        end

        return unpack_fn(results)
    end
end

local function vegasstuff_apply_cryptid_crossmod()
    vegasstuff_apply_cryptid_edeck_sprites()
    vegasstuff_apply_cryptid_tag_sprites()
    vegasstuff_hook_cryptid_shiny_tags()
end

if not _G.vegasstuff_cryptid_edeck_hooked then
    _G.vegasstuff_cryptid_edeck_hooked = true
    local vegasstuff_injectitems_ref = SMODS.injectItems
    local unpack_fn = table.unpack or unpack
    function SMODS.injectItems(...)
        local results = {}
        if type(vegasstuff_injectitems_ref) == "function" then
            results = { vegasstuff_injectitems_ref(...) }
        end
        pcall(vegasstuff_apply_cryptid_crossmod)
        return unpack_fn(results)
    end
end

pcall(vegasstuff_apply_cryptid_crossmod)
