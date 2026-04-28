
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
    Cryptid.edeck_sprites.edition.vegasstuff_retrowave = {atlas = deck_atlas, pos = {x = 6, y = 1}}
    Cryptid.edeck_sprites.edition.vegasstuff_event_horizon = {atlas = deck_atlas, pos = {x = 0, y = 2}, soul_pos = {x = 1, y = 2}}
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

local function vegasstuff_remove_miniscule_from_edeck()
    if not (SMODS.Mods.Cryptid and SMODS.Mods.Cryptid.can_load) then
        return
    end

    local miniscule = G and G.P_CENTERS and G.P_CENTERS.e_vegasstuff_miniscule
    if miniscule then
        miniscule.no_edeck = true
    end

    local profile = G and G.PROFILES and G.SETTINGS and G.PROFILES[G.SETTINGS.profile]
    if profile and profile.cry_edeck_edition == "vegasstuff_miniscule" then
        profile.cry_edeck_edition = "foil"
    end
end

local function vegasstuff_apply_cryptid_crossmod()
    vegasstuff_apply_cryptid_edeck_sprites()
    vegasstuff_apply_cryptid_tag_sprites()
    vegasstuff_hook_cryptid_shiny_tags()
    vegasstuff_remove_miniscule_from_edeck()
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

local function is_cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods["Cryptid"]
    return cryptid_mod and cryptid_mod.can_load
end

local function to_prob_number(value, fallback)
    if type(value) == "number" then
        return value
    end
    if type(value) == "string" then
        return tonumber(value) or fallback
    end
    if type(value) == "table" then
        if type(value.to_number) == "function" then
            local ok, n = pcall(function()
                return value:to_number()
            end)
            if ok and type(n) == "number" then
                return n
            end
        end
        if value.val ~= nil then
            return tonumber(value.val) or fallback
        end
    end
    if type(to_number) == "function" then
        local ok, n = pcall(function()
            return to_number(value)
        end)
        if ok and type(n) == "number" then
            return n
        end
    end
    return fallback
end

local function force_rigged_loc()
    if not (G and G.localization and G.localization.descriptions and G.localization.descriptions.Other) then
        return false
    end

    local source = G.localization.descriptions.Other.vegasstuff_cry_rigged_override
        or G.localization.descriptions.Other.cry_rigged
    if not source then
        return false
    end

    local entry = G.localization.descriptions.Other.cry_rigged or {}
    entry.name = source.name
    entry.text = copy_table(source.text or {})

    if type(loc_parse_string) == "function" then
        entry.name_parsed = { loc_parse_string(entry.name) }
        entry.text_parsed = {
            loc_parse_string(entry.text[1] or ""),
            loc_parse_string(entry.text[2] or ""),
            loc_parse_string(entry.text[3] or ""),
        }
    end

    G.localization.descriptions.Other.cry_rigged = entry
    return true
end

local function ensure_localize_hook()
    if _G.vegasstuff_rigged_localize_hooked or type(localize) ~= "function" then
        return
    end

    _G.vegasstuff_rigged_localize_hooked = true
    local localize_ref = localize
    function localize(args, misc_cat)
        if is_cryptid_active() and type(args) == "table" and args.type == "other" and args.key == "cry_rigged" then
            force_rigged_loc()
        end
        return localize_ref(args, misc_cat)
    end
end

local function apply_cryptid_rigged_override()
    ensure_localize_hook()
    if not is_cryptid_active() then
        return
    end

    force_rigged_loc()

    if not (SMODS and SMODS.Stickers and SMODS.Stickers["cry_rigged"]) then
        return
    end

    local rigged = SMODS.Stickers["cry_rigged"]
    rigged.loc_txt = G.localization.descriptions.Other.cry_rigged

    if rigged._vegasstuff_guarantee_override_applied then
        return
    end

    local rigged_calc_ref = rigged.calculate
    rigged.calculate = function(self, card, context)
        local out = type(rigged_calc_ref) == "function" and rigged_calc_ref(self, card, context) or nil

        if context and (context.mod_probability or context.fix_probability) and context.trigger_obj == card then
            local target = to_prob_number(context.denominator, nil) or to_prob_number(context.numerator, nil) or 1
            if target < 1 then
                target = 1
            end

            out = type(out) == "table" and out or {}
            out.numerator = target
            out.denominator = target
        end

        return out
    end

    rigged._vegasstuff_guarantee_override_applied = true
end

if not _G.vegasstuff_cryptid_rigged_hooked then
    _G.vegasstuff_cryptid_rigged_hooked = true
    local inject_ref = SMODS.injectItems
    if type(inject_ref) == "function" then
        local unpack_fn = table.unpack or unpack
        function SMODS.injectItems(...)
            local results = { inject_ref(...) }
            pcall(apply_cryptid_rigged_override)
            return unpack_fn(results)
        end
    end
end

pcall(apply_cryptid_rigged_override)

