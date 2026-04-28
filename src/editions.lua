do
_G.VegasStuff = _G.VegasStuff or {}
_G.VegasStuff.Boric = _G.VegasStuff.Boric or {}
_G.VegasStuff.Boric._applied_bonus = _G.VegasStuff.Boric._applied_bonus or 0

function _G.VegasStuff.Boric.is_boric_card(card)
    local ed = card and card.edition
    return ed and (ed.vegasstuff_boric or ed.type == "vegasstuff_boric" or ed.key == "e_vegasstuff_boric")
end

function _G.VegasStuff.Boric.count_highlighted_boric(cardarea)
    if not (cardarea and cardarea.highlighted) then
        return 0
    end

    local count = 0
    for _, highlighted_card in ipairs(cardarea.highlighted) do
        if _G.VegasStuff.Boric.is_boric_card(highlighted_card) then
            count = count + 1
        end
    end

    return count
end

function _G.VegasStuff.Boric.apply_bonus(target_bonus)
    if not (G and G.GAME and G.hand and SMODS and SMODS.change_play_limit and SMODS.change_discard_limit) then
        return false
    end

    local delta = target_bonus - (_G.VegasStuff.Boric._applied_bonus or 0)
    if delta ~= 0 then
        SMODS.change_play_limit(delta)
        SMODS.change_discard_limit(delta)
        _G.VegasStuff.Boric._applied_bonus = target_bonus
    end

    return true
end

function _G.VegasStuff.Boric.refresh_bonus()
    if not (G and G.hand) then
        return
    end
    _G.VegasStuff.Boric.apply_bonus(_G.VegasStuff.Boric.count_highlighted_boric(G.hand))
end

if not _G.VegasStuff.Boric._highlight_hooked then
    _G.VegasStuff.Boric._highlight_hooked = true
    local boric_add_to_highlighted_ref = CardArea.add_to_highlighted
    local boric_remove_from_highlighted_ref = CardArea.remove_from_highlighted
    local boric_unhighlight_all_ref = CardArea.unhighlight_all

    function CardArea:add_to_highlighted(card, silent)
        local temp_raised = false
        if self == G.hand and _G.VegasStuff.Boric.is_boric_card(card) and self.config and self.config.highlighted_limit and #self.highlighted >= self.config.highlighted_limit then
            _G.VegasStuff.Boric.apply_bonus((_G.VegasStuff.Boric._applied_bonus or 0) + 1)
            temp_raised = true
        end

        local results = { boric_add_to_highlighted_ref(self, card, silent) }
        if self == G.hand or temp_raised then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end

    function CardArea:remove_from_highlighted(card, forced)
        local results = { boric_remove_from_highlighted_ref(self, card, forced) }
        if self == G.hand then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end

    function CardArea:unhighlight_all()
        local results = { boric_unhighlight_all_ref(self) }
        if self == G.hand then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end
end

SMODS.Edition {
    key = 'boric',

    -- Use the Boric custom shader
    shader = "boric",

    in_shop = true,
    badge_colour = HEX('22BF33'),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,

    
    -- Custom draw path: avoid default _send payload for this shader.
    draw = function(self, card, layer)
        local send = card and card.ARGS and card.ARGS.send_to_shader or nil
        if card and card.children and card.children.center then
            card.children.center:draw_shader(self.shader, nil, send)
        end
        if card and card.children and card.children.front and not card:should_hide_front() then
            card.children.front:draw_shader(self.shader, nil, send)
        end
    end,

    unlocked = true,
    discovered = true,
    no_collection = false,

    get_weight = function(self)
        return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
    end,
}
end

do
local function event_horizon_empty_consumable_slots()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return math.max(0, (G.consumeables.config.card_limit or 0) - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0))
end

local function event_horizon_unscored_cards(context)
    local full = context and context.full_hand and #context.full_hand or 0
    local scoring = context and context.scoring_hand and #context.scoring_hand or full
    return math.max(0, full - scoring)
end

SMODS.Edition {
    key = "event_horizon",
    shader = "event_horizon",

    config = {
        base_x_mult = 1.15,
        unscored_x_mult = 0.18,
        empty_slot_x_mult = 0.05
    },

    

    loc_vars = function(self)
        return {
            vars = {
                self.config.base_x_mult,
                self.config.unscored_x_mult,
                self.config.empty_slot_x_mult
            }
        }
    end,

    in_shop = true,
    weight = 5,
    extra_cost = 4,
    badge_colour = HEX("2b154f"),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,
    unlocked = true,
    discovered = true,
    no_collection = false,

    get_weight = function(self)
        return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
    end,

    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            local x_mult = self.config.base_x_mult
                + event_horizon_unscored_cards(context) * self.config.unscored_x_mult
                + event_horizon_empty_consumable_slots() * self.config.empty_slot_x_mult

            return { x_mult = x_mult }
        end
    end,

    draw = function(self, card, layer)
        local send = card and card.ARGS and card.ARGS.send_to_shader or nil
        if card and card.children and card.children.center then
            card.children.center:draw_shader(self.shader, nil, send)
        end
        if card and card.children and card.children.front and not card:should_hide_front() then
            card.children.front:draw_shader(self.shader, nil, send)
        end
    end
}
end

do
local MINISCULE_SCALE = 0.65
local MINISCULE_EDITION_KEY = "e_vegasstuff_miniscule"

_G.VegasStuff = _G.VegasStuff or {}
Vegasstuff = _G.VegasStuff
Vegasstuff.miniscule_scale = MINISCULE_SCALE

function Vegasstuff.is_miniscule_edition(card)
    local edition = card and card.edition
    return edition
        and (
            edition.vegasstuff_miniscule
            or edition.type == "vegasstuff_miniscule"
            or edition.key == MINISCULE_EDITION_KEY
        )
end

function Vegasstuff.center_display_dimensions(card)
    local base_t = card and card.original_T
    if not base_t then
        return nil, nil
    end

    local width = base_t.w
    local height = base_t.h
    local center = card.config and card.config.center

    if center then
        if center.display_size and center.display_size.w then
            width = base_t.w * center.display_size.w / 71
        elseif center.pixel_size and center.pixel_size.w then
            width = base_t.w * center.pixel_size.w / 71
        end

        if center.display_size and center.display_size.h then
            height = base_t.h * center.display_size.h / 95
        elseif center.pixel_size and center.pixel_size.h then
            height = base_t.h * center.pixel_size.h / 95
        end
    end

    return width, height
end

function Vegasstuff.apply_miniscule_size(card)
    local base_t = card and card.original_T
    if not (card and card.T and base_t) then
        return
    end

    card.T.w = base_t.w * MINISCULE_SCALE
    card.T.h = base_t.h * MINISCULE_SCALE

    if card.VT then
        card.VT.w = card.T.w
        card.VT.h = card.T.h
    end
end

function Vegasstuff.restore_miniscule_size(card)
    if not (card and card.T) then
        return
    end

    local width, height = Vegasstuff.center_display_dimensions(card)
    if not (width and height) then
        return
    end

    card.T.w = width
    card.T.h = height

    if card.VT then
        card.VT.w = card.T.w
        card.VT.h = card.T.h
    end
end

SMODS.Edition {
    key = "miniscule",
    shader = "dissolve",
    badge_colour = HEX("a8c7c7"),
    weight = 0,
    in_shop = false,
    apply_to_float = false,
    unlocked = true,
    discovered = true,
    no_collection = true,
    
    draw = function(self, card, layer)
    end,
    on_apply = function(card)
        Vegasstuff.apply_miniscule_size(card)
    end,
    on_load = function(card)
        Vegasstuff.apply_miniscule_size(card)
    end,
    on_remove = function(card)
        Vegasstuff.restore_miniscule_size(card)
    end
}
end

do
local function retrowave_count_sevens(cards)
    local count = 0
    for _, played_card in ipairs(cards or {}) do
        if played_card.get_id and played_card:get_id() == 7 then
            count = count + 1
        end
    end
    return count
end

SMODS.Edition {
    key = "retrowave",
    shader = "retrowave",

    config = {
        chips = 77,
        mult = 7,
        dollars = 7
    },

    

    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.mult, self.config.dollars } }
    end,

    in_shop = true,
    weight = 7,
    extra_cost = 3,
    badge_colour = HEX("ff2fd6"),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,
    unlocked = true,
    discovered = true,
    no_collection = false,

    get_weight = function(self)
        return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
    end,

    calculate = function(self, card, context)
        if context.post_joker then
            local sevens = retrowave_count_sevens(context.scoring_hand)
            if sevens > 0 then
                return {
                    chips = self.config.chips * sevens,
                    mult = self.config.mult * sevens,
                    dollars = self.config.dollars * sevens
                }
            end
        end

        if context.main_scoring and context.cardarea == G.play and card and card.get_id and card:get_id() == 7 then
            return {
                chips = self.config.chips,
                mult = self.config.mult,
                dollars = self.config.dollars
            }
        end
    end,

    draw = function(self, card, layer)
        local send = card and card.ARGS and card.ARGS.send_to_shader or nil
        if card and card.children and card.children.center then
            card.children.center:draw_shader(self.shader, nil, send)
        end
        if card and card.children and card.children.front and not card:should_hide_front() then
            card.children.front:draw_shader(self.shader, nil, send)
        end
    end
}
end

do
local function draw_space_shader(self, card, layer)
    local send = card and card.ARGS and card.ARGS.send_to_shader or nil
    if card and card.children and card.children.center then
        card.children.center:draw_shader(self.shader, nil, send)
    end
    if card and card.children and card.children.front and not card:should_hide_front() then
        card.children.front:draw_shader(self.shader, nil, send)
    end
end

local function draw_realtime_space_shader(self, card, layer)
    local send = card and card.ARGS and card.ARGS.send_to_shader or nil
    local realtime_send = {
        send and send[1] or 0,
        G and G.TIMERS and G.TIMERS.REAL or send and send[2] or 0
    }

    if card and card.children and card.children.center then
        card.children.center:draw_shader(self.shader, nil, realtime_send)
    end
    if card and card.children and card.children.front and not card:should_hide_front() then
        card.children.front:draw_shader(self.shader, nil, realtime_send)
    end
end

local function draw_shader_layer(card, shader, send)
    if card and card.children and card.children.center then
        card.children.center:draw_shader(shader, nil, send)
    end
    if card and card.children and card.children.front and not card:should_hide_front() then
        card.children.front:draw_shader(shader, nil, send)
    end
end

local function draw_singularity_aquarium(self, card, layer)
    local send = card and card.ARGS and card.ARGS.send_to_shader or nil
    local realtime_send = {
        send and send[1] or 0,
        G and G.TIMERS and G.TIMERS.REAL or send and send[2] or 0
    }
    draw_shader_layer(card, "vegasstuff_singularity", realtime_send)
    draw_shader_layer(card, "vegasstuff_singularity_aquarium", realtime_send)
end

local function edition_weight(self)
    return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
end

local function geomancy_level(key)
    if Vegasstuff and Vegasstuff.get_geomancy_level then
        return Vegasstuff.get_geomancy_level(key)
    end
    return 0
end

local function total_geomancy_levels()
    local total = 0
    local keys = {
        "sol",
        "terra",
        "mars",
        "luna",
        "neptunus",
        "venus",
        "pluto",
        "mercurius",
        "saturnus",
        "uranus",
        "jupiter"
    }

    for _, key in ipairs(keys) do
        total = total + geomancy_level(key)
    end

    return total
end

local function used_consumables_from_set(set)
    local total = 0
    if not (G and G.GAME and G.GAME.consumeable_usage and G.P_CENTERS) then
        return 0
    end

    for key, usage in pairs(G.GAME.consumeable_usage) do
        local center = G.P_CENTERS[key]
        if center and center.set == set then
            total = total + (usage.count or 0)
        end
    end

    return total
end

local function empty_consumable_slots()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return math.max(0, (G.consumeables.config.card_limit or 0) - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0))
end

SMODS.Edition {
    key = "supernova",
    shader = "supernova",
    config = {
        base_x_mult = 1.35,
        sol_x_mult = 0.04,
        mars_x_mult = 0.03
    },
    
    loc_vars = function(self)
        return {
            vars = {
                self.config.base_x_mult,
                self.config.sol_x_mult,
                self.config.mars_x_mult
            }
        }
    end,
    in_shop = true,
    weight = 4,
    extra_cost = 6,
    badge_colour = HEX("ff7a18"),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    get_weight = edition_weight,
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            local x_mult = self.config.base_x_mult
                + geomancy_level("sol") * self.config.sol_x_mult
                + geomancy_level("mars") * self.config.mars_x_mult

            return { x_mult = x_mult }
        end
    end,
    draw = draw_realtime_space_shader
}

SMODS.Edition {
    key = "planetarium_deluxe",
    shader = "planetarium_deluxe",
    config = {
        chips_per_geomancy = 4,
        mult_per_zodiac = 2,
        base_chips = 25
    },
    
    loc_vars = function(self)
        return {
            vars = {
                self.config.chips_per_geomancy,
                self.config.mult_per_zodiac,
                self.config.base_chips
            }
        }
    end,
    in_shop = true,
    weight = 3,
    extra_cost = 7,
    badge_colour = HEX("31ffd4"),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    get_weight = edition_weight,
    calculate = function(self, card, context)
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            local chips = self.config.base_chips + total_geomancy_levels() * self.config.chips_per_geomancy
            local mult = used_consumables_from_set("zodiac") * self.config.mult_per_zodiac

            return {
                chips = chips,
                mult = mult
            }
        end
    end,
    draw = draw_realtime_space_shader
}

SMODS.Edition {
    key = "singularity_aquarium",
    shader = "singularity_aquarium",
    config = {
        base_x_mult = 1.2,
        empty_slot_x_mult = 0.18,
        max_retriggers = 2
    },
    
    loc_vars = function(self)
        return {
            vars = {
                self.config.base_x_mult,
                self.config.empty_slot_x_mult,
                self.config.max_retriggers
            }
        }
    end,
    in_shop = true,
    weight = 3,
    extra_cost = 7,
    badge_colour = HEX("101927"),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    get_weight = edition_weight,
    calculate = function(self, card, context)
        local empty_slots = empty_consumable_slots()

        if context.repetition and context.cardarea == G.play then
            local repetitions = math.min(self.config.max_retriggers, empty_slots)
            if repetitions > 0 then
                return { repetitions = repetitions }
            end
        end

        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                x_mult = self.config.base_x_mult + empty_slots * self.config.empty_slot_x_mult
            }
        end
    end,
    draw = draw_singularity_aquarium
}
end