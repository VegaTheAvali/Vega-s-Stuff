local FRACTURE_COST_FACTOR = 0.5
local FRACTURE_VALUE_FACTOR = 0.5

local function fracture_reduce_blind()
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) then
        return
    end

    local new_chips = to_big(G.GAME.blind.chips) * FRACTURE_VALUE_FACTOR
    if to_big(new_chips) < to_big(1) then
        new_chips = 1
    end

    G.GAME.blind.chips = Vegasstuff.to_number(new_chips, 1)
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
end

local function fracture_apply_cost_factor(card)
    if not (card and card.set_cost) then
        return
    end

    card.misprint_cost_fac = (card.misprint_cost_fac or 1) * FRACTURE_COST_FACTOR
    card:set_cost()
end

local function fracture_current_shop_cards()
    return {
        G.shop_jokers,
        G.shop_booster,
        G.shop_vouchers
    }
end

local function fracture_reduce_current_shop()
    for _, area in ipairs(fracture_current_shop_cards()) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                fracture_apply_cost_factor(card)
            end
        end
    end
end

local function fracture_joker_snapshot()
    local cards = {}

    if G and G.jokers and G.jokers.cards then
        for _, joker in ipairs(G.jokers.cards) do
            if joker
                and joker.ability
                and joker.ability.set == "Joker"
                and joker.config
                and joker.config.center
                and joker.config.center.rarity ~= 4
                and not joker.getting_sliced
            then
                cards[#cards + 1] = joker
            end
        end
    end

    return cards
end

local function fracture_consumable_snapshot()
    local cards = {}

    if G and G.consumeables and G.consumeables.cards then
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable and consumable.ability and consumable.ability.consumeable then
                cards[#cards + 1] = consumable
            end
        end
    end

    return cards
end

local function fracture_copy_joker(joker)
    local copy = copy_card(joker)
    copy:set_edition({ negative = true }, true, true)

    if Cryptid and Cryptid.manipulate then
        Cryptid.manipulate(copy, {
            type = "X",
            value = FRACTURE_VALUE_FACTOR,
            bypass_checks = true,
            no_deck_effects = true
        })
    end

    copy:add_to_deck()
    G.jokers:emplace(copy)
    copy:juice_up(0.3, 0.5)
end

local function fracture_copy_consumable(consumable)
    local copy = copy_card(consumable)
    copy:set_edition({ negative = true }, true, true)
    copy.ability.cry_multiuse = 1
    copy:add_to_deck()
    G.consumeables:emplace(copy)
    copy:juice_up(0.3, 0.5)
end

local function fracture_copy_all()
    for _, joker in ipairs(fracture_joker_snapshot()) do
        fracture_copy_joker(joker)
    end

    for _, consumable in ipairs(fracture_consumable_snapshot()) do
        fracture_copy_consumable(consumable)
    end
end

if not _G.vegasstuff_fracture_hooks_installed then
    _G.vegasstuff_fracture_hooks_installed = true

    local set_cost_ref = Card.set_cost
    function Card:set_cost(...)
        local results = { set_cost_ref(self, ...) }

        if G and G.GAME and G.GAME.vegasstuff_fracture_costs then
            if self.area == G.shop_jokers or self.area == G.shop_booster or self.area == G.shop_vouchers then
                if not self.ability.vegasstuff_fracture_costed then
                    self.ability.vegasstuff_fracture_costed = true
                    self.misprint_cost_fac = (self.misprint_cost_fac or 1) * (G.GAME.vegasstuff_fracture_costs or 1)
                    set_cost_ref(self, ...)
                end
            end
        end

        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "fracture",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return true
    end,
    use = function()
        G.GAME.vegasstuff_fracture_costs = (G.GAME.vegasstuff_fracture_costs or 1) * FRACTURE_COST_FACTOR
        fracture_reduce_blind()
        fracture_reduce_current_shop()
        fracture_copy_all()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 28)
