if _G.vegasstuff_spectrallib_hooks_installed then
    return
end
_G.vegasstuff_spectrallib_hooks_installed = true

local function spectrallib_active()
    return SMODS and SMODS.Mods and SMODS.Mods.Spectrallib
end

local function normalize_game_score_values()
    if not (G and G.GAME and spectrallib_active()) then
        return
    end

    if type(G.GAME.chips) == "table" then
        G.GAME.chips = Vegasstuff.to_number(G.GAME.chips, 0)
    end

    if G.GAME.blind and type(G.GAME.blind.chips) == "table" then
        G.GAME.blind.chips = Vegasstuff.to_number(G.GAME.blind.chips, 0)
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end
end

local game_update_ref = Game.update
function Game:update(dt)
    normalize_game_score_values()
    local results = {game_update_ref(self, dt)}
    normalize_game_score_values()
    return unpack(results)
end
