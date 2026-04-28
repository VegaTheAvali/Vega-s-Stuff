local VEGA_THRESHOLD = 5
local VEGA_DEFAULT_GEOMANCY_COUNT = 0
local VEGA_ALLOWED_SOURCES = {
    buf = true,
    jud = true,
    rif = true,
    rta = true,
    sou = true,
    uta = true,
    wra = true
}

local function vega_normalize_gain(value, fallback)
    local gain = math.max(0, tonumber(value) or fallback)
    if math.abs(gain) < 1e300 then
        gain = tonumber(string.format("%.2g", gain)) or gain
    end
    return gain
end

local function vega_format_gain_display(gain)
    if gain == math.floor(gain) then
        return tostring(math.floor(gain))
    end

    local text = string.format("%.2f", gain)
    while text:sub(-1) == "0" do
        text = text:sub(1, -2)
    end
    if text:sub(-1) == "." then
        text = text:sub(1, -2)
    end
    return text
end

local function vega_ensure_extra(self, card)
    card.ability.extra = card.ability.extra or {}
    if card.ability.extra.Geomancy_count == nil then
        card.ability.extra.Geomancy_count = card.ability.extra.Spec_count or VEGA_DEFAULT_GEOMANCY_COUNT
    end
    card.ability.extra.Spec_count = nil
    card.ability.extra.Geomancy_final = VEGA_THRESHOLD
    card.ability.extra.Spec_final = nil
    return card.ability.extra
end

local function vega_get_clamped_count(extra)
    local count = math.max(0, math.floor(tonumber(extra.Geomancy_count or extra.Spec_count or 0) or 0))
    return math.min(count, VEGA_THRESHOLD - 1)
end

local function vega_is_geomancy_consumable(consumeable)
    local ability_set = consumeable and consumeable.ability and consumeable.ability.set
    local center_set = consumeable and consumeable.config and consumeable.config.center and consumeable.config.center.set
    return ability_set == "geomancy" or center_set == "geomancy"
end

SMODS.Joker {
    key = "vega",
    config = {
        extra = {
            selection_gain = 1
        }
    },
    loc_txt = {
        ['name'] = 'Vega',
        ['text'] = {
            [1] = 'After every {C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} cards used,',
            [2] = 'gain {C:attention}+#3#{} {C:attention}selection limit{}',
            [3] = '{C:inactive}[#1#/#2#]{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 25,
    rarity = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    pools = { ["vegasstuff_mycustom_jokers"] = true },
    soul_pos = {
        x = 1,
        y = 0
    },
    in_pool = function(self, args)
        return not args or args.source ~= 'sho' or VEGA_ALLOWED_SOURCES[args.source]
    end,

    set_ability = function(self, card, initial, delay_sprites)
        local extra = vega_ensure_extra(self, card)
        extra.Geomancy_count = vega_get_clamped_count(extra)
        extra.selection_gain = vega_normalize_gain(extra.selection_gain or self.config.extra.selection_gain, self.config.extra.selection_gain)
        card.ability.extra = extra
    end,

    load = function(self, card, card_table, other_card)
        self:set_ability(card, false, false)
    end,

    loc_vars = function(self, info_queue, card)
        local extra = vega_ensure_extra(self, card)
        local count = vega_get_clamped_count(extra)
        local gain = vega_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
        extra.Geomancy_count = count
        return { vars = { count, VEGA_THRESHOLD, vega_format_gain_display(gain) } }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and vega_is_geomancy_consumable(context.consumeable) then
            return {
                func = function()
                    local extra = vega_ensure_extra(self, card)
                    local current = vega_get_clamped_count(extra)
                    local gain_per_trigger = vega_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
                    local updated = current + 1

                    if gain_per_trigger > 0 and updated >= VEGA_THRESHOLD then
                        local triggers = math.floor(updated / VEGA_THRESHOLD)
                        -- Integer boundary: round half up (0.5 and above rounds up).
                        local total_gain = math.max(0, math.floor((triggers * gain_per_trigger) + 0.5))
                        extra.Geomancy_count = updated - (triggers * VEGA_THRESHOLD)
                        if total_gain > 0 then
                            SMODS.change_play_limit(total_gain)
                            SMODS.change_discard_limit(total_gain)
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+"..tostring(total_gain).." Selection", colour = G.C.BLUE})
                        end
                    else
                        extra.Geomancy_count = updated
                    end
                    return true
                end
            }
        end
    end
}
