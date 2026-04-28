local ALT_TAB_HANDS = 1
local ALT_TAB_DISCARDS = 1
local ALT_TAB_BLIND_FACTOR = 0.5
local ALT_TAB_PACK_SELECTION = 1

local function alt_tab_random_booster_key()
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Booster
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center and center.key and center.set == "Booster" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return "p_arcana_normal_1"
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_alt_tab_pack"))
end

local function alt_tab_is_large_pack(booster)
    local ability = booster and booster.ability
    local center = booster and booster.config and booster.config.center
    local center_config = center and center.config
    local choose = tonumber(ability and ability.choose) or tonumber(center_config and center_config.choose) or 1
    local extra = tonumber(ability and ability.extra) or tonumber(center_config and center_config.extra) or 1

    return choose > 1 or extra >= 4
end

local function alt_tab_halve_blind()
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) then
        return
    end

    local new_chips = to_big(G.GAME.blind.chips) * ALT_TAB_BLIND_FACTOR
    G.GAME.blind.chips = Vegasstuff.to_number(new_chips, 1)
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
end

local function alt_tab_add_pack_selection()
    if not (G and G.GAME and G.GAME.modifiers) then
        return
    end

    G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + ALT_TAB_PACK_SELECTION
end

local function alt_tab_apply_return_effects(booster)
    if not (G and G.GAME and booster and booster.ability and booster.ability.vegasstuff_alt_tab) then
        return
    end

    booster.ability.vegasstuff_alt_tab = nil

    ease_hands_played(ALT_TAB_HANDS)
    ease_discard(ALT_TAB_DISCARDS)
    alt_tab_halve_blind()

    if alt_tab_is_large_pack(booster) then
        alt_tab_add_pack_selection()
    end
end

local function alt_tab_open_pack(source_card)
    local key = alt_tab_random_booster_key()
    local center = G.P_CENTERS and G.P_CENTERS[key]
    if not center then
        return
    end

    local source = source_card or {}
    local x = source.T and source.T.x or (G.play and (G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2)) or 0
    local y = source.T and source.T.y or (G.play and (G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2)) or 0

    local booster = Card(
        x,
        y,
        G.CARD_W * 1.27,
        G.CARD_H * 1.27,
        G.P_CARDS.empty,
        center,
        { bypass_discovery_center = true, bypass_discovery_ui = true }
    )

    booster.cost = 0
    booster.from_tag = true
    booster.ability.vegasstuff_alt_tab = true
    G.FUNCS.use_card({ config = { ref_table = booster } })
    booster:start_materialize()
end

if not _G.vegasstuff_alt_tab_hooks_installed then
    _G.vegasstuff_alt_tab_hooks_installed = true

    local card_open_ref = Card.open
    function Card:open(...)
        local results = { card_open_ref(self, ...) }
        alt_tab_apply_return_effects(self)
        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "alt_tab",
    loc_txt = {
        name = "://ALT_TAB",
        text = {
            "Open a free random {C:attention}Booster Pack{}",
            "Return with {C:blue}+#1#{} {C:attention}hand{}",
            "and {C:red}+#2#{} {C:attention}discard{}",
            "{C:attention}Halve{} the current {C:attention}Blind{}",
            "{C:attention}Mega/Jumbo{} packs gain",
            "{C:attention}+#3#{} {C:attention}pack selection{} this run"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            hands = ALT_TAB_HANDS,
            discards = ALT_TAB_DISCARDS,
            pack_selection = ALT_TAB_PACK_SELECTION
        }
    },
    loc_vars = function(self)
        return {
            vars = {
                self.config.extra.hands,
                self.config.extra.discards,
                self.config.extra.pack_selection
            }
        }
    end,
    can_use = function()
        return G
            and G.STATE == G.STATES.SELECTING_HAND
            and G.GAME
            and G.GAME.blind
            and G.GAME.blind.chips
            and not G.booster_pack
    end,
    use = function(self, card)
        alt_tab_open_pack(card)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 31)
