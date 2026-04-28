local EXPONENT_BASE_MULTIPLIER = 2
local EXPONENT_CONSUMABLE_USES = 1

local function exponent_owned_cards()
    local cards = {}

    if G and G.jokers and G.jokers.cards then
        for _, joker in ipairs(G.jokers.cards) do
            if joker
                and joker.ability
                and joker.ability.set == "Joker"
                and not joker.getting_sliced
                and not (Card.no and Card.no(joker, "immutable", true))
            then
                cards[#cards + 1] = joker
            end
        end
    end

    if G and G.consumeables and G.consumeables.cards then
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable and consumable.ability and consumable.ability.consumeable then
                cards[#cards + 1] = consumable
            end
        end
    end

    return cards
end

local function exponent_multiplier()
    local uses = G and G.GAME and G.GAME.vegasstuff_exponent_uses or 1
    return EXPONENT_BASE_MULTIPLIER ^ uses
end

local function exponent_apply_to_card(card, multiplier)
    if Cryptid and Cryptid.manipulate then
        Cryptid.manipulate(card, {
            type = "X",
            value = multiplier,
            bypass_checks = true
        })
    end

    if card.ability and card.ability.set == "Joker" and not (card.edition and card.edition.negative) then
        card:set_edition({ negative = true }, true, true)
    end

    if card.ability and card.ability.consumeable then
        card.ability.cry_multiuse = (card.ability.cry_multiuse or 1) + EXPONENT_CONSUMABLE_USES
    end

    if card.juice_up then
        card:juice_up(0.3, 0.5)
    end
end

Vegasstuff.retro_code_consumable({
    key = "exponent",
    loc_txt = {
        name = "://EXPONENT",
        text = {
            "Multiply all owned {C:attention}Jokers{}",
            "and {C:attention}consumables{}' {C:cry_code}listed values{}",
            "by {C:attention}#1#x{}",
            "Each use this run doubles",
            "this {C:attention}multiplier{} again",
            "Affected {C:attention}consumables{} gain",
            "{C:attention}+#2#{} use",
            "Affected {C:attention}Jokers{} become {C:dark_edition}Negative{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            base_multiplier = EXPONENT_BASE_MULTIPLIER,
            consumable_uses = EXPONENT_CONSUMABLE_USES
        }
    },
    loc_vars = function(self)
        return {
            vars = {
                self.config.extra.base_multiplier,
                self.config.extra.consumable_uses
            }
        }
    end,
    can_use = function()
        return #exponent_owned_cards() > 0
    end,
    use = function()
        G.GAME.vegasstuff_exponent_uses = (G.GAME.vegasstuff_exponent_uses or 0) + 1
        local multiplier = exponent_multiplier()

        for _, card in ipairs(exponent_owned_cards()) do
            exponent_apply_to_card(card, multiplier)
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 29)
