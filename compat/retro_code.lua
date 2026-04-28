local RETRO_CODE_SET = "RetroCode"
local RETRO_CODE_ATLAS = "RetroCodeCards"
local RETRO_CODE_COLUMNS = 12
local RETRO_CODE_ROWS = 7
local RETRO_CODE_MAX = (RETRO_CODE_COLUMNS * RETRO_CODE_ROWS) / 2

local function cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods.Cryptid
    return cryptid_mod and cryptid_mod.can_load
end

Vegasstuff.RETRO_CODE_SET = RETRO_CODE_SET

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
    local folder = "retro_codes"
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

if cryptid_active() then
    SMODS.ConsumableType {
        key = RETRO_CODE_SET,
        default = "c_vegasstuff_hardlock",
        primary_colour = HEX("39ff14"),
        secondary_colour = HEX("0b7f2a"),
        collection_rows = { 6, 6 },
        shop_rate = 0,
        loc_txt = {
            name = "Retro Code",
            collection = "Retro Code Cards",
            undiscovered = {
                name = "Undiscovered Retro Code",
                text = {
                    "Find this {C:green}Retro Code{} in",
                    "an old {C:attention}terminal{}"
                }
            }
        }
    }

    load_retro_code_cards()
end
