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
atlas("GeomancyPacks", "GeomancyPacks.png", 71, 95)
atlas("CustomJokers", "CustomJokers.png", 71, 95) 
atlas("CustomConsumables", "CustomConsumables.png", 71, 95) 
atlas("ZodiacCards", "ZodiacCards.png", 71, 95) 
atlas("CustomBoosters", "CustomBoosters.png", 71, 95) 
atlas("CustomEnhancements", "Enhancements.png", 71, 95) 
atlas("GeomancyCards", "GeomancyCards.png", 71, 95)
atlas("crypt_decks", "crypt_decks.png", 71, 95) 
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
safe_load_folder("editions")
safe_load_folder("decks")

-- =========================
-- REQUIRED FILES
-- =========================

pcall(function() assert(SMODS.load_file("rarities.lua"))() end)
pcall(function() assert(SMODS.load_file("boosters.lua"))() end)
pcall(function() assert(SMODS.load_file("enhancements.lua"))() end)
pcall(function() assert(SMODS.load_file("compat/cryptid.lua"))() end)

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
