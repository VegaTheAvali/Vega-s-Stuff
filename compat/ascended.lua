Vegasstuff = Vegasstuff or {}

local function vegas_cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods["Cryptid"]
    return cryptid_mod and cryptid_mod.can_load and Cryptid and Cryptid.calculate_ascension_power
end

local function vegas_get_flame_colour()
    if G and G.C and G.C.VEGAS_ASC_FLAME and type(G.C.VEGAS_ASC_FLAME) == "table" then
        return G.C.VEGAS_ASC_FLAME
    end
    if G and G.C then
        G.C.VEGAS_ASC_FLAME = { 14/255, 1.0, 0.0, 1.0 }
        return G.C.VEGAS_ASC_FLAME
    end
    return { 14/255, 1.0, 0.0, 1.0 }
end

local function vegas_get_ui_colour()
    if G and G.C and G.C.VEGAS_ASC_UI and type(G.C.VEGAS_ASC_UI) == "table" then
        return G.C.VEGAS_ASC_UI
    end
    if G and G.C then
        G.C.VEGAS_ASC_UI = { 14/255, 1.0, 0.0, 1.0 }
        return G.C.VEGAS_ASC_UI
    end
    return { 14/255, 1.0, 0.0, 1.0 }
end

local function vegas_to_number(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "string" then
        return tonumber(value) or 0
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
            return tonumber(value.val) or 0
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
    return 0
end

local function vegas_reset_current_hand_asc()
    if G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand then
        G.GAME.current_round.current_hand.vegas_asc_num = 0
        G.GAME.current_round.current_hand.vegas_asc_num_text = ""
    end
end

local function vegas_safe_array_len(t)
    return type(t) == "table" and #t or 0
end

local function vegas_apply_cryptid_asc_colour_hooks()
    if _G.vegasstuff_cryptid_asc_ui_colour_hooked then
        return
    end
    local cry_asc_ui_ref = G.FUNCS and G.FUNCS.cry_asc_UI_set
    if type(cry_asc_ui_ref) ~= "function" then
        return
    end
    _G.vegasstuff_cryptid_asc_ui_colour_hooked = true
    function G.FUNCS.cry_asc_UI_set(e)
        if vegas_cryptid_active() then
            if G.GAME and G.GAME.cry_exploit_override then
                e.config.object.colours = { darken(copy_table(vegas_get_ui_colour()), 0.2) }
            else
                e.config.object.colours = { vegas_get_ui_colour() }
            end
            e.config.object:update_text()
            return
        end
        return cry_asc_ui_ref(e)
    end
end

function Vegasstuff.ascension_enabled()
    return not vegas_cryptid_active()
end

function Vegasstuff.flame_highlight_colour()
    local default_highlight = (G and G.C and G.C.YELLOW) or { 1, 1, 0, 1 }
    if not (G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand) then
        return default_highlight
    end

    local hand = G.GAME.current_round.current_hand
    local vegas_active = vegas_to_number(hand.vegas_asc_num or 0) > 0
    local cryptid_active = vegas_to_number(hand.cry_asc_num or 0) > 0

    if vegas_active or cryptid_active then
        return vegas_get_flame_colour()
    end
    return default_highlight
end

function Vegasstuff.asc_flame_active()
    if not (G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand) then
        return false
    end
    local hand = G.GAME.current_round.current_hand
    return vegas_to_number(hand.vegas_asc_num or 0) > 0 or vegas_to_number(hand.cry_asc_num or 0) > 0
end

function Vegasstuff.asc_ui_colour()
    return vegas_get_ui_colour()
end

function Vegasstuff.hand_ascension_numbers(hand_name, tether)
    if hand_name == "High Card" then
        return tether and 1 or nil
    elseif hand_name == "Pair" then
        return tether and 2 or nil
    elseif hand_name == "Two Pair" then
        return 4
    elseif hand_name == "Three of a Kind" then
        return tether and 3 or nil
    elseif hand_name == "Straight" or hand_name == "Flush" or hand_name == "Straight Flush" then
        return next(SMODS.find_card("j_four_fingers")) and 4 or 5
    elseif
        hand_name == "Full House"
        or hand_name == "Five of a Kind"
        or hand_name == "Flush House"
        or hand_name == "Flush Five"
        or hand_name == "bunc_Spectrum"
        or hand_name == "bunc_Straight Spectrum"
        or hand_name == "bunc_Spectrum House"
        or hand_name == "bunc_Spectrum Five"
    then
        return 5
    elseif hand_name == "Four of a Kind" then
        return tether and 4 or nil
    elseif hand_name == "cry_Clusterfuck" or hand_name == "cry_UltPair" then
        return 8
    elseif hand_name == "cry_WholeDeck" then
        return 52
    elseif hand_name == "cry_Declare0" then
        return G.GAME.hands.cry_Declare0 and G.GAME.hands.cry_Declare0.declare_cards and #G.GAME.hands.cry_Declare0.declare_cards
    elseif hand_name == "cry_Declare1" then
        return G.GAME.hands.cry_Declare1 and G.GAME.hands.cry_Declare1.declare_cards and #G.GAME.hands.cry_Declare1.declare_cards
    elseif hand_name == "cry_Declare2" then
        return G.GAME.hands.cry_Declare2 and G.GAME.hands.cry_Declare2.declare_cards and #G.GAME.hands.cry_Declare2.declare_cards
    elseif
        hand_name == "spa_Spectrum"
        or hand_name == "spa_Straight_Spectrum"
        or hand_name == "spa_Spectrum_House"
        or hand_name == "spa_Spectrum_Five"
        or hand_name == "spa_Flush_Spectrum"
        or hand_name == "spa_Straight_Flush_Spectrum"
        or hand_name == "spa_Flush_Spectrum_House"
        or hand_name == "spa_Flush_Spectrum_Five"
    then
        return SpectrumAPI
                and SpectrumAPI.configuration.misc.four_fingers_spectrums
                and next(SMODS.find_card("j_four_fingers"))
                and 4
            or 5
    end
    return nil
end

function Vegasstuff.calculate_ascension_power(hand_name, hand_cards, hand_scoring_cards, tether, bonus)
    bonus = vegas_to_number(bonus)
    local starting = 0

    if not Vegasstuff.ascension_enabled() then
        return 0
    end

    if hand_name and hand_cards and hand_scoring_cards then
        local check = Vegasstuff.hand_ascension_numbers(hand_name, tether)
        if check then
            starting = (tether and vegas_safe_array_len(hand_cards) or vegas_safe_array_len(hand_scoring_cards)) - check
        end
    end

    if G and G.GAME and G.GAME.vegas_exploit_override then
        bonus = bonus + 1
    end

    local final = math.max(0, starting + bonus)
    if final > 0 and final < 1 then
        final = 1
    end
    return final
end

function Vegasstuff.ascend(num)
    if not Vegasstuff.ascension_enabled() then
        return num
    end

    G.GAME.vegas_sunnumber = G.GAME.vegas_sunnumber or { modest = 0, not_modest = 0 }

    local current_hand = (G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand) or nil
    local asc_num = vegas_to_number(current_hand and current_hand.vegas_asc_num or 0)
    if asc_num <= 0 then
        return num
    end

    local base = 1.25 + vegas_to_number(G.GAME.vegas_sunnumber.not_modest)
    local scalar = base ^ asc_num
    return num * (type(to_big) == "function" and to_big(scalar) or scalar)
end

G.FUNCS.vegasstuff_asc_UI_set = function(e)
    if Vegasstuff.ascension_enabled() then
        e.config.object.colours = { vegas_get_ui_colour() }
    else
        e.config.object.colours = { G.C.UI.TEXT_LIGHT }
    end
    e.config.object:update_text()
end

vegas_apply_cryptid_asc_colour_hooks()

if not _G.vegasstuff_cryptid_asc_inject_hooked then
    _G.vegasstuff_cryptid_asc_inject_hooked = true
    local inject_ref = SMODS.injectItems
    if type(inject_ref) == "function" then
        local unpack_fn = table.unpack or unpack
        function SMODS.injectItems(...)
            local results = { inject_ref(...) }
            pcall(vegas_apply_cryptid_asc_colour_hooks)
            return unpack_fn(results)
        end
    end
end

if not _G.vegasstuff_ascended_init_hooked then
    _G.vegasstuff_ascended_init_hooked = true
    local init_game_object_ref = Game.init_game_object
    function Game:init_game_object(...)
        local g = init_game_object_ref(self, ...)
        g.vegas_bonus_asc_power = vegas_to_number(g.vegas_bonus_asc_power)
        g.vegas_sunnumber = g.vegas_sunnumber or { modest = 0, not_modest = 0 }
        g.current_round = g.current_round or {}
        g.current_round.current_hand = g.current_round.current_hand or {}
        g.current_round.current_hand.vegas_asc_num = vegas_to_number(g.current_round.current_hand.vegas_asc_num)
        g.current_round.current_hand.vegas_asc_num_text = g.current_round.current_hand.vegas_asc_num_text or ""
        return g
    end
end

if not _G.vegasstuff_ascended_round_hooked then
    _G.vegasstuff_ascended_round_hooked = true
    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local result = evaluate_round_ref(...)
        if Vegasstuff.ascension_enabled() and G and G.C and G.C.UI_CHIPS and G.C.UI_CHIPS[1] == G.C.GOLD[1] then
            ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
            ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
        end
        return result
    end
end

if not _G.vegasstuff_ascended_hand_info_hooked then
    _G.vegasstuff_ascended_hand_info_hooked = true
    local get_poker_hand_info_ref = G.FUNCS.get_poker_hand_info
    function G.FUNCS.get_poker_hand_info(_cards)
        local text, loc_disp_text, poker_hands, scoring_hand, disp_text = get_poker_hand_info_ref(_cards)

        if not Vegasstuff.ascension_enabled() then
            vegas_reset_current_hand_asc()
            local current_hand = G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand
            local cry_asc = vegas_to_number(current_hand and current_hand.cry_asc_num or 0)
            local cry_text = current_hand and current_hand.cry_asc_num_text or ""
            if cry_asc > 0 and cry_text ~= "" then
                local asc_colour = copy_table(vegas_get_ui_colour())
                ease_colour(G.C.UI_CHIPS, asc_colour, 0.3)
                ease_colour(G.C.UI_MULT, copy_table(vegas_get_ui_colour()), 0.3)
            end
            return text, loc_disp_text, poker_hands, scoring_hand, disp_text
        end

        local hidden = false
        for _, v in pairs(scoring_hand or {}) do
            if v.facing == "back" then
                hidden = true
                break
            end
        end

        local tether = G and G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers.v_cry_hyperspacetether
        local bonus = G and G.GAME and G.GAME.vegas_bonus_asc_power or 0
        local a_power = Vegasstuff.calculate_ascension_power(text, _cards or {}, scoring_hand or {}, tether, bonus)
        a_power = vegas_to_number(a_power)

        if G and G.GAME and G.GAME.current_round and G.GAME.current_round.current_hand then
            G.GAME.current_round.current_hand.vegas_asc_num = a_power
            if a_power > 0 and not hidden then
                local asc_colour = copy_table(vegas_get_ui_colour())
                ease_colour(G.C.UI_CHIPS, asc_colour, 0.3)
                ease_colour(G.C.UI_MULT, copy_table(vegas_get_ui_colour()), 0.3)
                G.GAME.current_round.current_hand.vegas_asc_num_text = " (+" .. tostring(a_power) .. ")"
            else
                ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.3)
                ease_colour(G.C.UI_MULT, G.C.RED, 0.3)
                G.GAME.current_round.current_hand.vegas_asc_num_text = ""
            end
        end

        return text, loc_disp_text, poker_hands, scoring_hand, disp_text
    end
end
