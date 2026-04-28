local VEGAS_RIGGED_LOC = {
    name = "Rigged",
    text = {
        "All {C:cry_code}listed{} probabilities",
        "on this card are",
        "{C:green}guaranteed{}",
    },
}

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

    local entry = G.localization.descriptions.Other.cry_rigged or {}
    entry.name = VEGAS_RIGGED_LOC.name
    entry.text = { VEGAS_RIGGED_LOC.text[1], VEGAS_RIGGED_LOC.text[2], VEGAS_RIGGED_LOC.text[3] }

    if type(loc_parse_string) == "function" then
        entry.name_parsed = { loc_parse_string(entry.name) }
        entry.text_parsed = {
            loc_parse_string(entry.text[1]),
            loc_parse_string(entry.text[2]),
            loc_parse_string(entry.text[3]),
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
    rigged.loc_txt = VEGAS_RIGGED_LOC

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
