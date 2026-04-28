local LINK_JOKER_LEVEL_THRESHOLD = 5
local LINK_CONSUMABLE_CREATE_THRESHOLD = 5

local function link_count_area(area)
    return area and area.cards and #area.cards or 0
end

local function link_selected_hand()
    local cards = G and G.hand and G.hand.highlighted
    if cards and #cards > 0 then
        return G.FUNCS.get_poker_hand_info(cards)
    end

    cards = G and G.play and G.play.cards
    if cards and #cards > 0 then
        return G.FUNCS.get_poker_hand_info(cards)
    end
end

local function link_random_retro_code_key()
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_link" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_link_retro"))
end

local function link_create_retro_code()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return
    end

    if #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) >= G.consumeables.config.card_limit then
        return
    end

    local key = link_random_retro_code_key()
    if not key then
        return
    end

    SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
end

local function link_upgrade_hand(card, hand_name)
    local hand = G and G.GAME and G.GAME.hands and G.GAME.hands[hand_name]
    if not hand then
        return
    end

    local jokers = link_count_area(G.jokers)
    local consumables = link_count_area(G.consumeables)

    hand.mult = hand.mult + jokers
    hand.chips = hand.chips + consumables

    if jokers >= LINK_JOKER_LEVEL_THRESHOLD then
        level_up_hand(card, hand_name, nil, 1)
    end

    if consumables >= LINK_CONSUMABLE_CREATE_THRESHOLD then
        link_create_retro_code()
    end

    if G.hand then
        G.hand:unhighlight_all()
    end
end

Vegasstuff.retro_code_consumable({
    key = "link",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            mult_per_joker = 1,
            chips_per_consumable = 1,
            joker_threshold = LINK_JOKER_LEVEL_THRESHOLD,
            consumable_threshold = LINK_CONSUMABLE_CREATE_THRESHOLD
        }
    },
    loc_vars = function(self)
        return {
            vars = {
                self.config.extra.mult_per_joker,
                self.config.extra.chips_per_consumable,
                self.config.extra.joker_threshold,
                self.config.extra.consumable_threshold
            }
        }
    end,
    can_use = function()
        return G
            and G.hand
            and G.hand.highlighted
            and #G.hand.highlighted > 0
    end,
    use = function(self, card)
        local hand_name = link_selected_hand()
        if hand_name then
            link_upgrade_hand(card, hand_name)
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 17)
