local PSEUDO_EDITIONS = 3

local function pseudo_visible_areas()
    return {
        G.hand,
        G.jokers,
        G.consumeables,
        G.pack_cards,
        G.shop_jokers,
        G.shop_booster,
        G.shop_vouchers
    }
end

local function pseudo_visible_cards()
    local cards = {}

    for _, area in ipairs(pseudo_visible_areas()) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                cards[#cards + 1] = card
            end
        end
    end

    return cards
end

local function pseudo_apply_rigged(cards)
    for _, card in ipairs(cards) do
        card.ability.cry_rigged = true
        if card.juice_up then
            card:juice_up(0.15, 0.25)
        end
    end
end

local function pseudo_apply_random_editions(cards)
    local eligible = {}

    for _, card in ipairs(cards) do
        if not card.edition then
            eligible[#eligible + 1] = card
        end
    end

    pseudoshuffle(eligible, pseudoseed("vegasstuff_pseudo_editions"))

    for i = 1, math.min(PSEUDO_EDITIONS, #eligible) do
        local edition = SMODS.poll_edition({
            guaranteed = true,
            key = "vegasstuff_pseudo_" .. i
        })
        eligible[i]:set_edition(edition, true, true)
        if eligible[i].juice_up then
            eligible[i]:juice_up(0.3, 0.5)
        end
    end
end

local function pseudo_random_retro_code_key()
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_pseudo" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_pseudo_retro"))
end

local function pseudo_create_retro_code()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return
    end

    if #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) >= G.consumeables.config.card_limit then
        return
    end

    local key = pseudo_random_retro_code_key()
    if not key then
        return
    end

    SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
end

Vegasstuff.retro_code_consumable({
    key = "pseudo",
    loc_txt = {
        name = "://PSEUDO",
        text = {
            "Apply {C:green}Rigged{} to",
            "every visible {C:attention}card{}",
            "Give {C:attention}#1#{} random visible {C:attention}cards{}",
            "an {C:dark_edition}Edition{}",
            "Create a random {C:green}Retro Code{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            editions = PSEUDO_EDITIONS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.editions } }
    end,
    can_use = function()
        return true
    end,
    use = function()
        local cards = pseudo_visible_cards()
        pseudo_apply_rigged(cards)
        pseudo_apply_random_editions(cards)
        pseudo_create_retro_code()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 13)
