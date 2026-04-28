if not (Partner_API and Partner_API.Partner) then
    return
end

local VEGA_PARTNER_THRESHOLD = 5
local VEGA_PARTNER_DEFAULT_GEOMANCY_COUNT = 0
local VEGA_PARTNER_ATLAS = "vega_partner"
local VEGA_PARTNER_QUIP_KEY = "pnr_vegasstuff_vega"

-- Add, remove, or rewrite entries here for Vega's Partner speech bubbles.
local VEGA_PARTNER_QUIPS = {
    {
        "The stars are",
        "listening."
    },
    {
        "Asteres Planetai",
        "online."
    },
    {
        "Let's bend",
        "the hand limit."
    }
}

SMODS.Atlas {
    key = VEGA_PARTNER_ATLAS,
    path = "Partner.png",
    px = 44,
    py = 56
}

local function vega_partner_register_quips()
    if not G then
        return
    end

    G.localization = G.localization or {}
    G.localization.misc = G.localization.misc or {}
    G.localization.misc.quips = G.localization.misc.quips or {}

    for i, quip in ipairs(VEGA_PARTNER_QUIPS) do
        G.localization.misc.quips[VEGA_PARTNER_QUIP_KEY .. "_" .. i] = quip
    end
end

local function vega_partner_normalize_gain(value, fallback)
    local gain = math.max(0, tonumber(value) or fallback)
    if math.abs(gain) < 1e300 then
        gain = tonumber(string.format("%.2g", gain)) or gain
    end
    return gain
end

local function vega_partner_format_gain_display(gain)
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

local function vega_partner_ensure_extra(self, card)
    card.ability.extra = card.ability.extra or {}
    if card.ability.extra.Geomancy_count == nil then
        card.ability.extra.Geomancy_count = VEGA_PARTNER_DEFAULT_GEOMANCY_COUNT
    end

    card.ability.extra.Geomancy_final = VEGA_PARTNER_THRESHOLD
    card.ability.extra.selection_gain = vega_partner_normalize_gain(card.ability.extra.selection_gain, self.config.extra.selection_gain)
    return card.ability.extra
end

local function vega_partner_get_clamped_count(extra)
    local count = math.max(0, math.floor(tonumber(extra.Geomancy_count or 0) or 0))
    return math.min(count, VEGA_PARTNER_THRESHOLD - 1)
end

local function vega_partner_is_geomancy_consumable(consumeable)
    local ability_set = consumeable and consumeable.ability and consumeable.ability.set
    local center_set = consumeable and consumeable.config and consumeable.config.center and consumeable.config.center.set
    return ability_set == "geomancy" or center_set == "geomancy"
end

local function vega_partner_link_multiplier(self)
    local link_level = self.get_link_level and self:get_link_level() or 0
    if link_level and link_level > 0 then
        return 2
    end
    return 1
end

vega_partner_register_quips()

Partner_API.Partner {
    key = "vega",
    name = "Vega Partner",
    unlocked = true,
    discovered = true,
    individual_quips = true,
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    atlas = VEGA_PARTNER_ATLAS,
    config = { extra = { selection_gain = 1 } },
    link_config = { j_vegasstuff_vega = 1 },
    loc_txt = {
        name = "Vega",
        text = {
            "After every {C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} cards used,",
            "gain {C:attention}+#3#{} {C:attention}selection limit{}",
            "{C:inactive}[#1#/#2#]{}"
        }
    },
    set_ability = function(self, card, initial, delay_sprites)
        local extra = vega_partner_ensure_extra(self, card)
        extra.Geomancy_count = vega_partner_get_clamped_count(extra)
    end,
    load = function(self, card, card_table, other_card)
        self:set_ability(card, false, false)
    end,
    loc_vars = function(self, info_queue, card)
        local extra = vega_partner_ensure_extra(self, card)
        local count = vega_partner_get_clamped_count(extra)
        local gain = vega_partner_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
        extra.Geomancy_count = count

        return {
            vars = {
                count,
                VEGA_PARTNER_THRESHOLD,
                vega_partner_format_gain_display(gain * vega_partner_link_multiplier(self))
            }
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and vega_partner_is_geomancy_consumable(context.consumeable) then
            return {
                func = function()
                    local extra = vega_partner_ensure_extra(self, card)
                    local current = vega_partner_get_clamped_count(extra)
                    local gain_per_trigger = vega_partner_normalize_gain(extra.selection_gain, self.config.extra.selection_gain)
                    local updated = current + 1

                    if gain_per_trigger > 0 and updated >= VEGA_PARTNER_THRESHOLD then
                        local triggers = math.floor(updated / VEGA_PARTNER_THRESHOLD)
                        local total_gain = math.max(0, math.floor((triggers * gain_per_trigger * vega_partner_link_multiplier(self)) + 0.5))
                        extra.Geomancy_count = updated - (triggers * VEGA_PARTNER_THRESHOLD)

                        if total_gain > 0 then
                            SMODS.change_play_limit(total_gain)
                            SMODS.change_discard_limit(total_gain)
                            card_eval_status_text(card, "extra", nil, nil, nil, {
                                message = "+" .. tostring(total_gain) .. " Selection",
                                colour = G.C.BLUE
                            })
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
