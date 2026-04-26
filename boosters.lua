local PACK_GROUPS = {
    k_vegasstuff_astro_pack = "Astro Pack",
    k_vegasstuff_pack_of_creation = "Pack of Creation",
    k_vegasstuff_omega_pack = "Omega Pack",
    k_vegasstuff_zodiac_pack = "Zodiac Pack"
}

for key, name in pairs(PACK_GROUPS) do
    G.localization = G.localization or {}
    G.localization.misc = G.localization.misc or {}
    G.localization.misc.dictionary = G.localization.misc.dictionary or {}
    G.localization.misc.dictionary[key] = name
end

local function pack_loc_vars(self, info_queue, card)
    local cfg = (card and card.ability) or self.config
    return { vars = { cfg.choose, cfg.extra } }
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

SMODS.Booster {
    key = "pack_of_creation",
    loc_txt = {
        name = "Pack of Creation",
        text = {
            "Choose up to {C:gold}3{} of {C:gold}3{} selection cards",
            "{C:inactive}70% chance of{} {C:spectral}pointer{}",
            "{C:inactive}30% chance of {C:spectral}gateway{}"
        },
        group_name = "Pack of Creation"
    },
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
    loc_txt = {
        name = "Omega Pack",
        text = { "A pack with Omega cards" },
        group_name = "Omega Pack"
    },
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
        loc_txt = {
            name = args.name,
            text = {
                "Choose up to {C:attention}#1#{} of {C:attention}#2#{} " .. args.label .. " cards"
            },
            group_name = args.group_name
        },
        config = { extra = args.extra, choose = args.choose },
        cost = args.cost,
        atlas = args.atlas,
        pos = args.pos,
        group_key = args.group_key,
        select_card = "consumeables",
        discovered = true,
        loc_vars = pack_loc_vars,
        create_card = function()
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
            name = variant.name,
            label = common.label,
            group_name = common.group_name,
            extra = variant.extra,
            choose = variant.choose,
            cost = variant.cost,
            atlas = common.atlas,
            pos = variant.pos,
            group_key = common.group_key,
            set = common.set
        }
    end
end

register_pack_variants({
    label = "Geomancy",
    group_name = "Astro Pack",
    atlas = "GeomancyPacks",
    group_key = "k_vegasstuff_astro_pack",
    set = "geomancy"
}, {
    { key = "geomancy_pack", name = "Astro Pack", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "geomancy_pack2", name = "Astro Pack", extra = 3, choose = 1, pos = { x = 1, y = 0 } },
    { key = "geomancy_pack3", name = "Astro Pack", extra = 3, choose = 1, pos = { x = 2, y = 0 } },
    { key = "geomancy_pack4", name = "Astro Pack", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "jumbo_geomancy_pack", name = "Jumbo Astro Pack", extra = 5, choose = 1, pos = { x = 0, y = 1 } },
    { key = "jumbo_geomancy_pack2", name = "Jumbo Astro Pack", extra = 5, choose = 1, pos = { x = 1, y = 1 } },
    { key = "mega_geomancy_pack", name = "Mega Astro Pack", extra = 5, choose = 2, pos = { x = 2, y = 1 } },
    { key = "mega_geomancy_pack2", name = "Mega Astro Pack", extra = 5, choose = 2, pos = { x = 3, y = 1 } },
    { key = "mini_geomancy_pack", name = "Mini Astro Pack", extra = 2, choose = 1, pos = { x = 0, y = 2 } },
    { key = "mini_geomancy_pack2", name = "Mini Astro Pack", extra = 2, choose = 1, pos = { x = 1, y = 2 } }
})

register_pack_variants({
    label = "Zodiac",
    group_name = "Zodiac Pack",
    atlas = "ZodiacPacks",
    group_key = "k_vegasstuff_zodiac_pack",
    set = "zodiac"
}, {
    { key = "zodiac_pack", name = "Zodiac Pack", extra = 3, choose = 1, pos = { x = 0, y = 0 } },
    { key = "zodiacpack2", name = "Zodiac Pack", extra = 3, choose = 1, pos = { x = 1, y = 0 } },
    { key = "zodiacpack3", name = "Zodiac Pack", extra = 3, choose = 1, pos = { x = 2, y = 0 } },
    { key = "zodiacpack4", name = "Zodiac Pack", extra = 3, choose = 1, pos = { x = 3, y = 0 } },
    { key = "jumbo_zodiac_pack", name = "Jumbo Zodiac Pack", extra = 5, choose = 1, cost = 6, pos = { x = 0, y = 1 } },
    { key = "jumbozodiacpack2", name = "Jumbo Zodiac Pack", extra = 5, choose = 1, cost = 6, pos = { x = 1, y = 1 } },
    { key = "mega_zodiac_pack", name = "Mega Zodiac Pack", extra = 5, choose = 2, cost = 6, pos = { x = 2, y = 1 } },
    { key = "megazodiacpack2", name = "Mega Zodiac Pack", extra = 5, choose = 2, cost = 6, pos = { x = 3, y = 1 } },
    { key = "minizodiacpack", name = "Mini Zodiac Pack", extra = 2, choose = 1, cost = 6, pos = { x = 0, y = 2 } },
    { key = "minizodiacpack2", name = "Mini Zodiac Pack", extra = 2, choose = 1, cost = 6, pos = { x = 1, y = 2 } }
})