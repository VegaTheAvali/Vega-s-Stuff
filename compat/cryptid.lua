
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

if not _G.vegasstuff_cryptid_edeck_hooked then
    _G.vegasstuff_cryptid_edeck_hooked = true
    local vegasstuff_injectitems_ref = SMODS.injectItems
    local unpack_fn = table.unpack or unpack
    function SMODS.injectItems(...)
        local results = {}
        if type(vegasstuff_injectitems_ref) == "function" then
            results = { vegasstuff_injectitems_ref(...) }
        end
        pcall(vegasstuff_apply_cryptid_edeck_sprites)
        return unpack_fn(results)
    end
end

pcall(vegasstuff_apply_cryptid_edeck_sprites)
