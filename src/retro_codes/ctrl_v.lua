local CTRL_V_COPIES = 3

local function ctrl_v_areas()
    local areas = {}
    if G.hand then
        areas[#areas + 1] = G.hand
    end
    if G.jokers then
        areas[#areas + 1] = G.jokers
    end
    if G.consumeables then
        areas[#areas + 1] = G.consumeables
    end
    if G.pack_cards then
        areas[#areas + 1] = G.pack_cards
    end
    if G.shop_jokers then
        areas[#areas + 1] = G.shop_jokers
    end
    if G.shop_booster then
        areas[#areas + 1] = G.shop_booster
    end
    if G.shop_vouchers then
        areas[#areas + 1] = G.shop_vouchers
    end
    return areas
end

local function ctrl_v_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards(ctrl_v_areas(), card, 1, 1, function(target)
        return target and target.ability and target.config and target.config.center
    end)
end

local function ctrl_v_center_set(card)
    return card and card.config and card.config.center and card.config.center.set
end

local function ctrl_v_ability_set(card)
    return card and card.ability and card.ability.set
end

local function ctrl_v_is_playing_card(card)
    local set = ctrl_v_ability_set(card) or ctrl_v_center_set(card)
    return card and (card.playing_card or set == "Default" or set == "Enhanced")
end

local function ctrl_v_is_joker(card)
    local set = ctrl_v_ability_set(card) or ctrl_v_center_set(card)
    return set == "Joker" or card.area == G.jokers or card.area == G.shop_jokers
end

local function ctrl_v_is_booster(card)
    local set = ctrl_v_ability_set(card) or ctrl_v_center_set(card)
    return set == "Booster" or card.area == G.shop_booster
end

local function ctrl_v_is_voucher(card)
    local set = ctrl_v_ability_set(card) or ctrl_v_center_set(card)
    return set == "Voucher" or card.area == G.shop_vouchers
end

local function ctrl_v_expand_area(area, needed)
    if area and area.config and area.config.card_limit and #area.cards + needed > area.config.card_limit then
        area.config.card_limit = #area.cards + needed
    end
end

local function ctrl_v_prepare_consumable(copy)
    if copy.ability and copy.ability.name == "cry-Chambered" and copy.ability.extra then
        copy.ability.extra.num_copies = 1
    end
    if Incantation and copy.setQty then
        copy:setQty(1)
    end
end

local function ctrl_v_copy_to_deck(target)
    G.playing_card = (G.playing_card or 0) + 1
    local copy = copy_card(target, nil, nil, G.playing_card)
    copy:add_to_deck()
    table.insert(G.playing_cards, copy)
    if G.hand then
        G.hand:emplace(copy)
    elseif G.deck then
        G.deck:emplace(copy)
    end
    if playing_card_joker_effects then
        playing_card_joker_effects({ copy })
    end
    copy:start_materialize()
    return copy
end

local function ctrl_v_copy_to_jokers(target)
    ctrl_v_expand_area(G.jokers, 1)
    local copy = copy_card(target)
    copy:add_to_deck()
    G.jokers:emplace(copy)
    copy:start_materialize()
    return copy
end

local function ctrl_v_copy_to_consumables(target)
    ctrl_v_expand_area(G.consumeables, 1)
    local copy = copy_card(target)
    ctrl_v_prepare_consumable(copy)
    copy:add_to_deck()
    G.consumeables:emplace(copy)
    copy:start_materialize()
    return copy
end

local function ctrl_v_copy_booster(target)
    local copy = copy_card(target)
    copy.cost = 0
    copy.from_tag = true
    copy:start_materialize()
    G.FUNCS.use_card({ config = { ref_table = copy } })
    return copy
end

local function ctrl_v_copy_voucher(target)
    local copy = copy_card(target)
    copy.cost = 0
    copy.from_tag = true
    copy:start_materialize()
    G.FUNCS.use_card({ config = { ref_table = copy } })
    return copy
end

local function ctrl_v_copy_card(target)
    if ctrl_v_is_playing_card(target) then
        return ctrl_v_copy_to_deck(target)
    end

    if ctrl_v_is_joker(target) then
        return ctrl_v_copy_to_jokers(target)
    end

    if ctrl_v_is_booster(target) then
        return ctrl_v_copy_booster(target)
    end

    if ctrl_v_is_voucher(target) then
        return ctrl_v_copy_voucher(target)
    end

    return ctrl_v_copy_to_consumables(target)
end

local function ctrl_v_clear_highlights()
    for _, area in ipairs(ctrl_v_areas()) do
        if area.unhighlight_all then
            area:unhighlight_all()
        end
    end
end

Vegasstuff.retro_code_consumable({
    key = "ctrl_v",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            copies = CTRL_V_COPIES
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.copies } }
    end,
    can_use = function(self, card)
        return #ctrl_v_selected_card(card) == 1
    end,
    use = function(self, card)
        local selected = ctrl_v_selected_card(card)[1]
        if not selected then
            return
        end

        for i = 1, CTRL_V_COPIES do
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.05 * i,
                func = function()
                    local copy = ctrl_v_copy_card(selected)
                    if copy then
                        copy:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end

        ctrl_v_clear_highlights()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 32)
