local BASE_TARGET_BUYS = 10
local MIN_TARGET_BUYS = 1

local function level()
    return Vegasstuff.get_geomancy_level("mercurius")
end

local function is_active()
    return level() > 0
end

local function required_buys()
    return math.max(MIN_TARGET_BUYS, BASE_TARGET_BUYS - level())
end

local function get_counter()
    if not (G and G.GAME) then
        return 0
    end
    local current = math.min(required_buys(), Vegasstuff.safe_int(G.GAME.vegasstuff_mercurius_buy_counter, 0))
    G.GAME.vegasstuff_mercurius_buy_counter = current
    return current
end

local function set_counter(value)
    if G and G.GAME then
        G.GAME.vegasstuff_mercurius_buy_counter = math.min(required_buys(), Vegasstuff.safe_int(value, 0))
    end
end

local function process_consumable_purchase(card)
    if not (card and card.ability and card.ability.consumeable and is_active()) then
        return
    end

    local required = required_buys()
    local counter = get_counter()
    if counter >= required then
        card:set_edition({ negative = true }, true, true)
        set_counter(0)
        card_eval_status_text(card, "extra", nil, nil, nil, {
            message = "Negative!",
            colour = G.C.DARK_EDITION or G.C.PURPLE,
        })
    else
        set_counter(counter + 1)
    end
end

Vegasstuff.register_shop_purchase_callback("mercurius", process_consumable_purchase)

SMODS.Consumable {
    key = "mercurius",
    config = {
        extra = {
            max_level = 9,
            tracker_key = "mercurius",
            fallback_center_key = "c_vegasstuff_mercurius"
        }
    },
    set = "geomancy",
    pos = { x = 4, y = 1 },
    soul_pos = { x = 5, y = 1 },
    loc_txt = {
        name = '{C:vegasstuff_name_mercurius}Mercurius{}',
        text = {
            [1] = "After buying {C:attention}#1#{} consumables,",
            [2] = "the next bought consumable becomes {C:dark_edition}Negative{}",
            [3] = "{C:inactive}(Progress #2#/#1#, Level #3#/#4#){}"
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = "GeomancyCards",
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self, { solar_disabled = true })
    end,
    loc_vars = function(self)
        return { vars = { required_buys(), get_counter(), level(), self.config.extra.max_level } }
    end,
    can_use = function(self)
        return Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local current_level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if current_level >= extra.max_level then
            return
        end

        Vegasstuff.set_geomancy_level_from_extra(extra, current_level + 1)
        set_counter(0)
        Vegasstuff.juice_and_status(used_card, "Need " .. tostring(required_buys()) .. " consumables", G.C.DARK_EDITION or G.C.PURPLE)
    end,
}