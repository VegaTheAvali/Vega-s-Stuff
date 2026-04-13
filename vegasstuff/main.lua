local NFS = require("nativefs")

to_big = to_big or function(a) return a end
lenient_bignum = lenient_bignum or function(a) return a end

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
atlas("balatro", "balatro.png", 333, 216) 

atlas("CustomJokers", "CustomJokers.png", 71, 95) 
atlas("CustomConsumables", "CustomConsumables.png", 71, 95) 
atlas("ZodiacCards", "ZodiacCards.png", 71, 95) 
atlas("CustomBoosters", "CustomBoosters.png", 71, 95) 
atlas("CustomEnhancements", "CustomEnhancements.png", 71, 95) 

atlas("WarTorn", "WarTorn.png", 71, 95) 
atlas("Anaphase", "Anaphase.png", 71, 95) 
atlas("Duality", "Duality.png", 71, 95) 
atlas("Toxin", "Toxin.png", 71, 95) 
atlas("Rusted", "Rusted.png", 71, 95) 
atlas("Stitched", "Stitched.png", 71, 95) 
atlas("Tapered", "Tapered.png", 71, 95) 
atlas("Midas", "Midas.png", 71, 95) 
atlas("Dreamy", "Dreamy.png", 71, 95) 
atlas("Soggy", "Soggy.png", 71, 95) 
atlas("Scoped", "Scoped.png", 71, 95) 
atlas("Creased", "Creased.png", 71, 95) 

atlas("Crypt_decks", "Crypt_decks.png", 71, 95) 
atlas("ZodiacPacks", "ZodiacPacks.png", 71, 95) 
atlas("CustomDecks", "CustomDecks.png", 71, 95)
-- =========================
-- SAFE LOADER
-- =========================

local function safe_load_folder(folder)
    local dir = SMODS.current_mod.path .. "/" .. folder
    local files = NFS.getDirectoryItems(dir)

    if not files then
        print("[Boric] Missing folder: " .. folder)
        return
    end

    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            local ok, err = pcall(function()
                assert(SMODS.load_file(folder .. "/" .. file))()
            end)

            if not ok then
                print("[Boric] ERROR loading " .. file .. ": " .. tostring(err))
            end
        end
    end
end

safe_load_folder("jokers")
safe_load_folder("consumables")
safe_load_folder("enhancements")
safe_load_folder("editions")
safe_load_folder("decks")

-- =========================
-- REQUIRED FILES
-- =========================

pcall(function() assert(SMODS.load_file("rarities.lua"))() end)
pcall(function() assert(SMODS.load_file("boosters.lua"))() end)

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
-- SUIT SKINS (WORKING FORMAT)
-- =========================
-- NOTE: No Palette system used (not supported in your setup)

local suits = {
    {key = "wands", pos = {x = 0, y = 0}},
    {key = "swords", pos = {x = 1, y = 0}},
    {key = "chalices", pos = {x = 2, y = 0}},
    {key = "pentacles", pos = {x = 3, y = 0}},
}

for _, s in ipairs(suits) do
    SMODS.DeckSkin {
        key = "vegasstuff_tarotdeck_" .. s.key,
        suit = s.key:gsub("^%l", string.upper), -- Wands, Swords, etc.

        palettes = {
            {
                key = s.key .. "_default",
                suit = s.key:gsub("^%l", string.upper),

                atlas = "TarotDeck",
                pos = s.pos,

                ranks = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
            }
        }
    }
end

-- =========================
-- OPTIONAL FEATURES
-- =========================

SMODS.current_mod.optional_features = function()
    return {
        cardareas = {}
    }
end