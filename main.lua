local NFS = require("nativefs")

to_big = to_big or function(a) return a end
lenient_bignum = lenient_bignum or function(a) return a end

_G.VegasStuff = _G.VegasStuff or {}
Vegasstuff = _G.VegasStuff

COLLAGE_MODIFIED_TABLE_MINOR = COLLAGE_MODIFIED_TABLE_MINOR or {}
COLLAGE_MODIFIED_TABLE_MAJOR = COLLAGE_MODIFIED_TABLE_MAJOR or {}
COLLAGE_MODIFIED_TABLE = COLLAGE_MODIFIED_TABLE or {}

local VEGASSTUFF_GEOMANCY_MAX_LEVELS = {
    sol = 20,
    terra = 5,
    mars = 20,
    luna = 20,
    neptunus = 20,
    venus = 20,
    pluto = 20,
    mercurius = 9,
    saturnus = 4,
    uranus = 4,
    jupiter = 5
}

local VEGASSTUFF_GEOMANCY_LEGACY_LEVELS = {
    sol = "vegasstuff_sol_level",
    neptunus = "vegasstuff_neptunus_level",
    pluto = "vegasstuff_pluto_level"
}

function Vegasstuff.safe_int(value, fallback)
    return math.max(0, math.floor(tonumber(value) or fallback or 0))
end

function Vegasstuff.format_number(value, digits)
    local precision = digits or 2
    local formatted = string.format("%." .. tostring(precision) .. "f", tonumber(value) or 0)
    return formatted:gsub("0+$", ""):gsub("%.$", "")
end

function Vegasstuff.get_geomancy_level(key)
    if not (G and G.GAME and key) then
        return 0
    end

    local levels = G.GAME.vegasstuff_geomancy_levels or {}
    local usage = (G.GAME.consumeable_usage and G.GAME.consumeable_usage["c_vegasstuff_" .. key]) or {}
    local legacy_key = VEGASSTUFF_GEOMANCY_LEGACY_LEVELS[key]
    return math.max(
        Vegasstuff.safe_int(levels[key], 0),
        Vegasstuff.safe_int(usage.count, 0),
        legacy_key and Vegasstuff.safe_int(G.GAME[legacy_key], 0) or 0
    )
end

function Vegasstuff.get_geomancy_level_from_extra(extra)
    if not (G and G.GAME and extra and extra.tracker_key) then
        return 0
    end

    G.GAME.vegasstuff_geomancy_levels = G.GAME.vegasstuff_geomancy_levels or {}
    local tracked_level = G.GAME.vegasstuff_geomancy_levels[extra.tracker_key]

    if tracked_level == nil then
        local usage = (G.GAME.consumeable_usage and G.GAME.consumeable_usage[extra.fallback_center_key]) or {}
        tracked_level = usage.count or 0
    end

    tracked_level = math.min(Vegasstuff.safe_int(extra.max_level, 20), Vegasstuff.safe_int(tracked_level, 0))
    G.GAME.vegasstuff_geomancy_levels[extra.tracker_key] = tracked_level
    return tracked_level
end

function Vegasstuff.set_geomancy_level_from_extra(extra, level)
    if not (G and G.GAME and extra and extra.tracker_key) then
        return
    end

    G.GAME.vegasstuff_geomancy_levels = G.GAME.vegasstuff_geomancy_levels or {}
    G.GAME.vegasstuff_geomancy_levels[extra.tracker_key] = math.min(
        Vegasstuff.safe_int(extra.max_level, 20),
        Vegasstuff.safe_int(level, 0)
    )
end

function Vegasstuff.get_geomancy_max_level(center)
    if center and center.config and center.config.extra and center.config.extra.max_level then
        return Vegasstuff.safe_int(center.config.extra.max_level, 0)
    end

    return VEGASSTUFF_GEOMANCY_MAX_LEVELS[center and center.key] or 20
end

function Vegasstuff.can_spawn_geomancy_card(center, opts)
    if not (G and G.GAME and center and center.key) then
        return true
    end

    if opts and opts.solar_disabled and G.GAME.modifiers and G.GAME.modifiers.vegasstuff_solar_deck then
        return false
    end

    return Vegasstuff.get_geomancy_level(center.key) < Vegasstuff.get_geomancy_max_level(center)
end

function Vegasstuff.geomancy_can_use(center)
    return Vegasstuff.get_geomancy_level_from_extra(center.config.extra) < Vegasstuff.safe_int(center.config.extra.max_level, 20)
end

function Vegasstuff.tiered_geomancy_gain(extra, level)
    local safe_level = math.max(1, Vegasstuff.safe_int(level, 1))
    local tier = math.floor((safe_level - 1) / Vegasstuff.safe_int(extra.tier_levels, 4))
    if extra.tier_mode == "add" then
        return (tonumber(extra.base_gain) or 0) + tier
    end
    return (tonumber(extra.base_gain) or 0) * (2 ^ tier)
end

function Vegasstuff.total_tiered_geomancy_gain(extra, level)
    local total = 0
    for i = 1, Vegasstuff.safe_int(level, 0) do
        total = total + Vegasstuff.tiered_geomancy_gain(extra, i)
    end
    return total
end

function Vegasstuff.apply_permanent_to_deck(stat_key, amount, mode)
    if not (G and G.playing_cards and stat_key) then
        return 0
    end

    local applied = 0
    for _, playing_card in ipairs(G.playing_cards) do
        playing_card.ability = playing_card.ability or {}
        local current = tonumber(playing_card.ability[stat_key]) or 0
        if mode == "max" then
            playing_card.ability[stat_key] = math.max(current, amount)
        else
            playing_card.ability[stat_key] = current + amount
        end
        applied = applied + 1
    end
    return applied
end

function Vegasstuff.juice_and_status(card, message, colour)
    if card then
        card:juice_up(0.3, 0.5)
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = message,
            colour = colour
        })
    end
end

Vegasstuff.shop_purchase_callbacks = Vegasstuff.shop_purchase_callbacks or {}

function Vegasstuff.register_shop_purchase_callback(key, callback)
    Vegasstuff.shop_purchase_callbacks[key] = callback
end

if G and G.FUNCS and G.FUNCS.buy_from_shop and not _G.vegasstuff_buy_from_shop_hooked then
    _G.vegasstuff_buy_from_shop_hooked = true
    local buy_from_shop_ref = G.FUNCS.buy_from_shop
    function G.FUNCS.buy_from_shop(e)
        local bought_card = e and e.config and e.config.ref_table
        local out = buy_from_shop_ref(e)

        if bought_card and bought_card.is and bought_card:is(Card) then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.2,
                func = function()
                    if bought_card and bought_card.added_to_deck then
                        for _, callback in pairs(Vegasstuff.shop_purchase_callbacks) do
                            callback(bought_card)
                        end
                    end
                    return true
                end,
            }))
        end

        return out
    end
end

Vegasstuff.consumable_name_colours = {
    vegasstuff_name_aquarius = HEX("a472da"),
    vegasstuff_name_aries = HEX("a472da"),
    vegasstuff_name_cancer = HEX("a472da"),
    vegasstuff_name_capricorn = HEX("a472da"),
    vegasstuff_name_gemini = HEX("a472da"),
    vegasstuff_name_leo = HEX("a472da"),
    vegasstuff_name_libra = HEX("a472da"),
    vegasstuff_name_pisces = HEX("a472da"),
    vegasstuff_name_sagittarius = HEX("a472da"),
    vegasstuff_name_scorpio = HEX("a472da"),
    vegasstuff_name_taurus = HEX("a472da"),
    vegasstuff_name_virgo = HEX("a472da"),
    vegasstuff_name_sol = HEX("f8585a"),
    vegasstuff_name_terra = HEX("26cc00"),
    vegasstuff_name_mars = HEX("c60000"),
    vegasstuff_name_luna = HEX("26a7fb"),
    vegasstuff_name_neptunus = HEX("1099ac"),
    vegasstuff_name_venus = HEX("ffd21f"),
    vegasstuff_name_pluto = HEX("e62351"),
    vegasstuff_name_mercurius = HEX("7322e9"),
    vegasstuff_name_saturnus = HEX("ff9352"),
    vegasstuff_name_uranus = HEX("0030cc"),
    vegasstuff_name_jupiter = HEX("fc809f")
}

local function vegasstuff_register_loc_colours()
    if not (G and G.ARGS and G.ARGS.LOC_COLOURS) then
        return
    end

    for key, colour in pairs(Vegasstuff.consumable_name_colours) do
        G.ARGS.LOC_COLOURS[key] = colour
    end
end

if type(loc_colour) == "function" and not _G.vegasstuff_loc_colour_hooked then
    _G.vegasstuff_loc_colour_hooked = true
    local loc_colour_ref = loc_colour
    function loc_colour(colour_key, default)
        local colour = loc_colour_ref(colour_key, default)
        vegasstuff_register_loc_colours()
        return (G and G.ARGS and G.ARGS.LOC_COLOURS and G.ARGS.LOC_COLOURS[colour_key]) or colour
    end
end

-- =========================
-- SHADERS
-- =========================

SMODS.Shaders = SMODS.Shaders or {}

SMODS.Shader {
    key = "boric",
    path = "boric.fs"
}

-- =========================
-- ATLAS
-- =========================

local function atlas(key, path, px, py)
    SMODS.Atlas({
        key = key,
        path = path,
        px = px,
        py = py,
        atlas_table = "ASSET_ATLAS"
    })
end

atlas("modicon", "ModIcon.png", 34, 34)
SMODS.Atlas({
    key = "balatro",
    path = "balatro.png",
    px = 333,
    py = 216,
    atlas_table = "ASSET_ATLAS",
    prefix_config = { key = false }
})
atlas("GeomancyPacks", "GeomancyPacks.png", 71, 95)
atlas("CustomJokers", "CustomJokers.png", 71, 95)
atlas("ZodiacCards", "ZodiacCards.png", 71, 95)
atlas("CustomBoosters", "CustomBoosters.png", 71, 95)
atlas("CustomEnhancements", "Enhancements.png", 71, 95)
atlas("GeomancyCards", "GeomancyCards.png", 71, 95)
atlas("crypt_decks", "crypt_decks.png", 71, 95)
atlas("ZodiacPacks", "ZodiacPacks.png", 71, 95)
atlas("CustomDecks", "CustomDecks.png", 71, 95)
atlas("Vouchers", "Vouchers.png", 71, 95)
atlas("vegasstuff_tags", "tags.png", 34, 34)
atlas("vegasstuff_shinytags", "shinytags.png", 34, 34)
-- =========================
-- SAFE LOADER
-- =========================

local function safe_load_folder(folder)
    local dir = SMODS.current_mod.path .. "/" .. folder
    local files = NFS.getDirectoryItems(dir)

    if not files then
        print("[VegasStuff] Missing folder: " .. folder)
        return
    end

    table.sort(files, function(a, b)
        if a == "sets.lua" then return true end
        if b == "sets.lua" then return false end
        return a < b
    end)

    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            local ok, err = pcall(function()
                assert(SMODS.load_file(folder .. "/" .. file))()
            end)

            if not ok then
                print("[VegasStuff] ERROR loading " .. file .. ": " .. tostring(err))
            end
        end
    end
end

local function safe_load_file(path)
    local ok, err = pcall(function()
        assert(SMODS.load_file(path))()
    end)

    if not ok then
        print("[VegasStuff] ERROR loading " .. path .. ": " .. tostring(err))
    end
end

safe_load_folder("jokers")
safe_load_folder("consumables")
safe_load_folder("editions")
safe_load_folder("decks")
safe_load_folder("tags")
safe_load_folder("vouchers")
safe_load_folder("ui")

-- =========================
-- REQUIRED FILES
-- =========================

safe_load_file("rarities.lua")
safe_load_file("boosters.lua")
safe_load_file("enhancements.lua")
safe_load_file("compat/cryptid.lua")
safe_load_file("compat/ascended.lua")
safe_load_file("compat/cryptid_rigged.lua")
safe_load_file("compat/revos_vault.lua")

-- =========================
-- OBJECT TYPES
-- =========================

SMODS.ObjectType({
    key = "vegasstuff_food",
    cards = {
        ["j_gros_michel"] = true,
        ["j_egg"] = true,
        ["j_ice_cream"] = true,
        ["j_cavendish"] = true,
        ["j_turtle_bean"] = true,
        ["j_diet_cola"] = true,
        ["j_popcorn"] = true,
        ["j_ramen"] = true,
        ["j_selzer"] = true
    },
})

SMODS.ObjectType({
    key = "vegasstuff_mycustom_jokers",
    cards = {
        ["j_vegasstuff_theseized"] = true,
        ["j_vegasstuff_vega"] = true
    },
})

-- =========================
-- OPTIONAL FEATURES
-- =========================

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {}
    }
end
