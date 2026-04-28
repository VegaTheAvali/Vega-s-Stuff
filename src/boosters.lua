local function numeric_value(value, fallback)
    if type(to_number) == "function" then
        value = to_number(value)
    end

    return tonumber(value) or fallback
end

local function booster_size_mod()
    return numeric_value(G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.booster_size_mod, 0)
end

local function booster_choice_mod()
    return numeric_value(G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.booster_choice_mod, 0)
end

local function effective_pack_extra(cfg)
    return math.max(1, Vegasstuff.safe_int(numeric_value(cfg and cfg.extra, 1) + booster_size_mod(), 1))
end

local function effective_pack_choose(cfg)
    local extra = effective_pack_extra(cfg)
    local choose = Vegasstuff.safe_int(numeric_value(cfg and cfg.choose, 1) + booster_choice_mod(), 1)
    return math.min(choose, extra), extra
end

local function pack_loc_vars(self, info_queue, card)
    local cfg = (card and card.ability) or self.config
    local choose, extra = effective_pack_choose(cfg)
    return { vars = { choose, extra } }
end

local function pack_particles()
    G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
        timer = 0.015,
        scale = 0.2,
        initialize = true,
        lifespan = 1,
        speed = 1.1,
        padding = -1,
        attach = G.ROOM_ATTACH,
        colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
        fill = true
    })
    G.booster_pack_sparkles.fade_alpha = 1
    G.booster_pack_sparkles:fade(1, 0)
end

local function purple_pack_background()
    ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
    ease_background_colour({ new_colour = HEX("49006d"), special_colour = HEX("d178ff"), contrast = 2 })
end

local function creation_pack_background()
    ease_colour(G.C.DYN_UI.MAIN, HEX("0082f9"))
    ease_background_colour({ new_colour = HEX("0082f9"), special_colour = HEX("cdbb53"), contrast = 2 })
end

local function pack_card(set, key_append)
    return {
        set = set,
        area = G.pack_cards,
        skip_materialize = true,
        soulable = true,
        key_append = key_append
    }
end

local function keyed_pack_card(key, set, key_append)
    local card = pack_card(set, key_append)
    card.key = key
    return card
end

local function solar_deck_active()
    return G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.vegasstuff_solar_deck
end

local function geomancy_tracker_key(center)
    return Vegasstuff.geomancy_tracker_key(center)
end

local function is_maxed_geomancy_center(center)
    local tracker_key = geomancy_tracker_key(center)
    return center
        and center.set == "geomancy"
        and tracker_key ~= "croptid"
        and Vegasstuff.get_geomancy_level(tracker_key) >= Vegasstuff.get_geomancy_max_level(center)
end

local function geomancy_pack_choices(key_append)
    local choices = {}
    local pool = (G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.geomancy) or {}
    local croptid_key = "c_vegasstuff_croptid"

    for _, center in ipairs(pool) do
        local tracker_key = geomancy_tracker_key(center)
        if center and tracker_key and tracker_key ~= "croptid" then
            if solar_deck_active() and is_maxed_geomancy_center(center) and G.P_CENTERS and G.P_CENTERS[croptid_key] then
                choices[#choices + 1] = {
                    key = croptid_key,
                    source = key_append .. "_maxed_geomancy_replacement"
                }
            elseif SMODS.add_to_pool(center, { source = key_append }) then
                choices[#choices + 1] = {
                    key = center.key,
                    source = key_append
                }
            end
        end
    end

    return choices
end

local function geomancy_pack_has_choices()
    return #geomancy_pack_choices("vegasstuff_geomancy_pack_probe") > 0
end

local function geomancy_pack_card(key_append)
    local choices = geomancy_pack_choices(key_append)
    if #choices == 0 then
        return pack_card("geomancy", key_append)
    end

    local selected_index = pseudorandom("vegasstuff_geomancy_candidate_" .. key_append, 1, #choices)
    local choice = choices[selected_index]
    return keyed_pack_card(choice.key, "geomancy", choice.source)
end

local function apply_geomancy_pack_choices()
    if not (G and G.GAME and SMODS and SMODS.OPENED_BOOSTER) then
        return
    end

    local booster = SMODS.OPENED_BOOSTER
    local cfg = (booster and booster.ability)
        or (booster and booster.config and booster.config.center and booster.config.center.config)
        or {}
    local choose, extra = effective_pack_choose(cfg)
    G.GAME.pack_size = extra
    G.GAME.pack_choices = choose
end

local function geomancy_pack_UIBox(self)
    apply_geomancy_pack_choices()
    return SMODS.Booster.create_UIBox(self)
end

local function consumable_pack_in_pool(args)
    if args.set ~= "geomancy" then
        return nil
    end

    return function()
        return geomancy_pack_has_choices()
    end
end

SMODS.Booster {
    key = "pack_of_creation",
    config = { extra = 3, choose = 1 },
    weight = 7.5,
    atlas = "CustomBoosters",
    dependencies = { "Cryptid" },
    pos = { x = 0, y = 0 },
    group_key = "k_vegasstuff_pack_of_creation",
    discovered = true,
    loc_vars = pack_loc_vars,
    create_card = function()
        local key = pseudorandom("vegasstuff_pack_of_creation_card") <= 0.7 and "c_cry_pointer" or "c_cry_gateway"
        return keyed_pack_card(key, "Spectral", "vegasstuff_pack_of_creation")
    end,
    ease_background_colour = creation_pack_background,
    particles = pack_particles
}

local OMEGA_KEYS = {
    "black_hole_omega",
    "ankh_omega",
    "aura_omega",
    "soul_omega",
    "cryptid_omega",
    "ectoplasm_omega",
    "familiar_omega",
    "grim_omega",
    "hex_omega",
    "immolate_omega",
    "incantation_omega",
    "ouija_omega",
    "sigil_omega",
    "wraith_omega",
    "fool_omega",
    "high_priestess_omega",
    "emperor_omega",
    "hermit_omega",
    "wheel_of_fortune_omega"
}

SMODS.Booster {
    key = "omega_pack",
    config = { extra = 3, choose = 1 },
    atlas = "CustomBoosters",
    dependencies = { "Polterworx" },
    pos = { x = 1, y = 0 },
    soul_pos = { x = 2, y = 0 },
    group_key = "k_vegasstuff_omega_pack",
    draw_hand = true,
    select_card = "consumeables",
    discovered = true,
    loc_vars = pack_loc_vars,
    create_card = function()
        local selected_index = pseudorandom("vegasstuff_omega_pack_card", 1, #OMEGA_KEYS)
        return keyed_pack_card(OMEGA_KEYS[selected_index], "Tarot", "vegasstuff_omega_pack")
    end,
    particles = pack_particles
}

local function register_consumable_pack(args)
    SMODS.Booster {
        key = args.key,
        config = { extra = args.extra, choose = args.choose },
        cost = args.cost,
        atlas = args.atlas,
        pos = args.pos,
        group_key = args.group_key,
        draw_hand = args.draw_hand,
        discovered = true,
        in_pool = consumable_pack_in_pool(args),
        loc_vars = pack_loc_vars,
        create_UIBox = args.set == "geomancy" and geomancy_pack_UIBox or nil,
        create_card = function()
            if args.set == "geomancy" then
                return geomancy_pack_card("vegasstuff_" .. args.key)
            end
            return pack_card(args.set, "vegasstuff_" .. args.key)
        end,
        ease_background_colour = purple_pack_background,
        particles = pack_particles
    }
end

local function register_pack_variants(common, variants)
    for _, variant in ipairs(variants) do
        register_consumable_pack {
            key = variant.key,
            extra = variant.extra,
            choose = variant.choose,
            cost = variant.cost,
            atlas = common.atlas,
            pos = variant.pos,
            group_key = common.group_key,
            set = common.set,
            draw_hand = common.draw_hand
        }
    end
end

register_pack_variants({
    atlas = "GeomancyPacks",
    group_key = "k_vegasstuff_astro_pack",
    set = "geomancy"
}, {
    { key = "geomancy_pack", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "geomancy_pack2", extra = 3, choose = 1, pos = { x = 1, y = 0 } },
    { key = "geomancy_pack3", extra = 3, choose = 1, pos = { x = 2, y = 0 } },
    { key = "geomancy_pack4", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "jumbo_geomancy_pack", extra = 5, choose = 1, pos = { x = 0, y = 1 } },
    { key = "jumbo_geomancy_pack2", extra = 5, choose = 1, pos = { x = 1, y = 1 } },
    { key = "mega_geomancy_pack", extra = 5, choose = 2, pos = { x = 2, y = 1 } },
    { key = "mega_geomancy_pack2", extra = 5, choose = 2, pos = { x = 3, y = 1 } },
    { key = "mini_geomancy_pack", extra = 2, choose = 1, pos = { x = 0, y = 2 } },
    { key = "mini_geomancy_pack2", extra = 2, choose = 1, pos = { x = 1, y = 2 } }
})

register_pack_variants({
    atlas = "ZodiacPacks",
    group_key = "k_vegasstuff_zodiac_pack",
    set = "zodiac",
    draw_hand = true
}, {
    { key = "zodiac_pack", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "zodiacpack2", extra = 3, choose = 1, pos = { x = 1, y = 0 } },
    { key = "zodiacpack3", extra = 3, choose = 1, pos = { x = 2, y = 0 } },
    { key = "zodiacpack4", extra = 3, choose = 1, pos = { x = 3, y = 0 } },
    { key = "jumbo_zodiac_pack", extra = 5, choose = 1, cost = 6, pos = { x = 0, y = 1 } },
    { key = "jumbozodiacpack2", extra = 5, choose = 1, cost = 6, pos = { x = 1, y = 1 } },
    { key = "mega_zodiac_pack", extra = 5, choose = 2, cost = 6, pos = { x = 2, y = 1 } },
    { key = "megazodiacpack2", extra = 5, choose = 2, cost = 6, pos = { x = 3, y = 1 } },
    { key = "minizodiacpack", extra = 2, choose = 1, cost = 6, pos = { x = 0, y = 2 } },
    { key = "minizodiacpack2", extra = 2, choose = 1, cost = 6, pos = { x = 1, y = 2 } }
})
