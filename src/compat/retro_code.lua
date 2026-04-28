local NFS = require("nativefs")
local RETRO_CODE_SET = "RetroCode"
local RETRO_CODE_ATLAS = "RetroCodeCards"
local RETRO_CODE_COLUMNS = 12
local RETRO_CODE_ROWS = 7
local RETRO_CODE_MAX = (RETRO_CODE_COLUMNS * RETRO_CODE_ROWS) / 2
local RETRO_CODE_REPLACE_CHANCE = 0.1

local function cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods.Cryptid
    return cryptid_mod and cryptid_mod.can_load
end

Vegasstuff.RETRO_CODE_SET = RETRO_CODE_SET
Vegasstuff.RETRO_CODE_REPLACE_CHANCE = RETRO_CODE_REPLACE_CHANCE

function Vegasstuff.retro_code_sprite(index)
    index = math.floor(tonumber(index) or 0)
    assert(index >= 1 and index <= RETRO_CODE_MAX, "Retro Code sprite index must be between 1 and " .. RETRO_CODE_MAX)

    local base_index = (index - 1) * 2
    local x = base_index % RETRO_CODE_COLUMNS
    local y = math.floor(base_index / RETRO_CODE_COLUMNS)

    return {
        atlas = RETRO_CODE_ATLAS,
        pos = { x = x, y = y },
        soul_pos = { x = x + 1, y = y }
    }
end

function Vegasstuff.retro_code_consumable(def, sprite_index)
    def = def or {}
    local sprite = Vegasstuff.retro_code_sprite(sprite_index or def.sprite_index or 1)

    def.set = def.set or RETRO_CODE_SET
    def.atlas = def.atlas or sprite.atlas
    def.pos = def.pos or sprite.pos
    def.soul_pos = def.soul_pos or sprite.soul_pos

    return SMODS.Consumable(def)
end

local function load_retro_code_cards()
    local folder = "src/retro_codes"
    local dir = SMODS.current_mod.path .. "/" .. folder
    local ok, files = pcall(NFS.getDirectoryItems, dir)

    if not ok or not files then
        return
    end

    table.sort(files)
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            local loaded, err = pcall(function()
                assert(SMODS.load_file(folder .. "/" .. file))()
            end)

            if not loaded then
                print("[VegasStuff] ERROR loading " .. folder .. "/" .. file .. ": " .. tostring(err))
            end
        end
    end
end

local function retro_code_replacement_key(key_append)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[RETRO_CODE_SET]
    if not pool or #pool == 0 then
        return nil
    end

    local choices = {}
    for _, center in ipairs(pool) do
        if center and center.key and SMODS.add_to_pool(center, { source = "vegasstuff_retro_code_replace" }) then
            choices[#choices + 1] = center.key
        end
    end

    if #choices == 0 then
        return nil
    end

    return choices[pseudorandom("vegasstuff_retro_code_pick_" .. tostring(key_append or ""), 1, #choices)]
end

local function should_replace_code_card(key_append)
    if not G or not G.GAME then
        return false
    end

    local ante = G.GAME.round_resets and G.GAME.round_resets.ante or 0
    local seed = "vegasstuff_retro_code_replace_" .. tostring(ante) .. "_" .. tostring(key_append or "")
    return pseudorandom(seed) < RETRO_CODE_REPLACE_CHANCE
end

local function install_retro_code_replacement_hook()
    if _G.vegasstuff_retro_code_replace_hooked then
        return
    end

    _G.vegasstuff_retro_code_replace_hooked = true
    local create_card_ref = create_card

    function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        if _type == "Code" and not forced_key and should_replace_code_card(key_append) then
            local replacement_key = retro_code_replacement_key(key_append)
            if replacement_key then
                return create_card_ref(RETRO_CODE_SET, area, legendary, _rarity, skip_materialize, soulable, replacement_key, key_append)
            end
        end

        return create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    end
end

if cryptid_active() then
    SMODS.ConsumableType {
        key = RETRO_CODE_SET,
        default = "c_vegasstuff_hardlock",
        primary_colour = HEX("39ff14"),
        secondary_colour = HEX("0b7f2a"),
        collection_rows = { 6, 6 },
        shop_rate = 0,
    }

    load_retro_code_cards()
    install_retro_code_replacement_hook()
end
