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
atlas("lmfao", "lmfao.png", 71, 95)
atlas("RetroCodeCards", "RetroCodeCards.png", 71, 95)
atlas("CustomEnhancements", "Enhancements.png", 71, 95)
atlas("GeomancyCards", "GeomancyCards.png", 71, 95)
atlas("crypt_decks", "crypt_decks.png", 71, 95)
atlas("ZodiacPacks", "ZodiacPacks.png", 71, 95)
atlas("CustomDecks", "CustomDecks.png", 71, 95)
atlas("Vouchers", "Vouchers.png", 71, 95)
atlas("vegasstuff_stake", "Stake.png", 29, 29)
atlas("vegasstuff_tags", "tags.png", 34, 34)
atlas("vegasstuff_shinytags", "shinytags.png", 34, 34)
atlas("SuitsLC", "SuitsLC.png", 71, 95)
atlas("SuitsHC", "SuitsHC.png", 71, 95)
atlas("SuitsUILC", "SuitsUILC.png", 18, 18)
atlas("SuitsUIHC", "SuitsUIHC.png", 18, 18)
-- =========================
