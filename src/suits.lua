do
local SUITS = {
    {
        key = "Swords",
        card_key = "SWORDS",
        pos = { x = 0, y = 0 },
        ui_pos = { x = 0, y = 0 },
        lc_colour = HEX("ff2f5f"),
        hc_colour = HEX("ff5a78"),
        calculate = function(self, card, context)
            if context.main_scoring then
                if card.vegasstuff_sword_hand ~= context.scoring_hand then
                    card.vegasstuff_sword_hand = context.scoring_hand
                    card.vegasstuff_sword_scores = 0
                end
                card.vegasstuff_sword_scores = (card.vegasstuff_sword_scores or 0) + 1
            elseif context.repetition_only and card.vegasstuff_sword_hand == context.scoring_hand
                and card.base.nominal > context.other_card.base.nominal then
                return { repetitions = card.vegasstuff_sword_scores or 0, card = card }
            end
        end,
    },
    {
        key = "Cups",
        card_key = "CUPS",
        pos = { x = 0, y = 1 },
        ui_pos = { x = 1, y = 0 },
        lc_colour = HEX("00a6d9"),
        hc_colour = HEX("33c4ff"),
        calculate = function(self, card, context)
            return {
                func = function()
                    G.GAME.vegasstuff_chalice = (G.GAME.vegasstuff_chalice or 0) + card.base.nominal
                    while G.GAME.vegasstuff_chalice >= 45
                        and #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit do
                        G.GAME.vegasstuff_chalice = G.GAME.vegasstuff_chalice - 45
                        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                SMODS.add_card {
                                    set = pseudorandom("vegasstuff_chalice_reward") < 0.5 and "Tarot" or "zodiac",
                                    area = G.consumeables,
                                    key_append = "vegasstuff_chalice",
                                }
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                                return true
                            end,
                        }))
                    end
                    card_eval_status_text(card, "extra", nil, nil, nil, {
                        message = localize { type = "variable", key = "a_vegasstuff_chalice", vars = { G.GAME.vegasstuff_chalice, 45 } },
                        colour = G.C.SUITS.vegasstuff_Cups,
                    })
                    return true
                end,
            }
        end,
    },
    {
        key = "Pentacles",
        card_key = "PENTACLES",
        pos = { x = 0, y = 2 },
        ui_pos = { x = 2, y = 0 },
        lc_colour = HEX("ff8a26"),
        hc_colour = HEX("ffb13b"),
        calculate = function(self, card, context)
            if SMODS.pseudorandom_probability(card, "vegasstuff_pentacles", card.base.nominal, 15) then
                return { dollars = 1 }
            end
        end,
    },
    {
        key = "Wands",
        card_key = "WANDS",
        pos = { x = 0, y = 3 },
        ui_pos = { x = 3, y = 0 },
        lc_colour = HEX("6d4a8f"),
        hc_colour = HEX("9d72d9"),
        calculate = function(self, card, context)
            return {
                func = function()
                    for i, played_card in ipairs(G.play.cards) do
                        if played_card == card then
                            for _, offset in ipairs({ -1, 1 }) do
                                if G.play.cards[i + offset] then
                                    G.play.cards[i + offset].ability.perma_bonus =
                                        (G.play.cards[i + offset].ability.perma_bonus or 0) + card.base.nominal
                                    card_eval_status_text(G.play.cards[i + offset], "extra", nil, nil, nil, {
                                        message = localize { type = "variable", key = "a_chips", vars = { card.base.nominal } },
                                        colour = G.C.CHIPS,
                                    })
                                end
                            end
                            break
                        end
                    end
                    return true
                end,
            }
        end,
    }
}

for _, suit in ipairs(SUITS) do
    SMODS.Suit {
        key = suit.key,
        card_key = suit.card_key,
        hidden = true,

        lc_atlas = "SuitsLC",
        hc_atlas = "SuitsHC",
        lc_ui_atlas = "SuitsUILC",
        hc_ui_atlas = "SuitsUIHC",

        pos = suit.pos,
        ui_pos = suit.ui_pos,
        lc_colour = suit.lc_colour,
        hc_colour = suit.hc_colour,
        calculate = suit.calculate,

        in_pool = function(self, args)
            return not (args and args.initial_deck)
        end
    }
end
end


local eval_card_ref = eval_card
function eval_card(card, context)
    local effects, post = eval_card_ref(card, context)
    if context.cardarea == G.play and not card.debuff and card.base
        and not SMODS.has_no_suit(card) and not SMODS.has_no_rank(card) then
        if context.main_scoring then
            if SMODS.Suits[card.base.suit] and SMODS.Suits[card.base.suit].calculate then
                effects.playing_card = SMODS.merge_effects(
                    { effects.playing_card }, { SMODS.Suits[card.base.suit]:calculate(card, context) })
            end
        elseif context.repetition_only and context.repetition then
            for i, played_card in ipairs(G.play.cards) do
                if played_card == card then
                    if i > 1 and G.play.cards[i - 1].base.suit == "vegasstuff_Swords"
                        and not G.play.cards[i - 1].debuff
                        and not SMODS.has_no_suit(G.play.cards[i - 1])
                        and not SMODS.has_no_rank(G.play.cards[i - 1])
                        and SMODS.in_scoring(G.play.cards[i - 1], context.scoring_hand) then
                        effects.vegasstuff_swords = SMODS.Suits.vegasstuff_Swords:calculate(G.play.cards[i - 1], context)
                        if effects.vegasstuff_swords and effects.vegasstuff_swords.repetitions <= 0 then
                            effects.vegasstuff_swords = nil
                        end
                    end
                    break
                end
            end
        end
    end
    return effects, post
end

local generate_UIBox_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    local ui = generate_UIBox_ability_table_ref(self, ...)
    if self.base and self.base.suit and not self.debuff and not SMODS.has_no_suit(self) and not SMODS.has_no_rank(self)
        and G.localization.descriptions.Other["vegasstuff_suit_" .. self.base.suit] then
        local vars = { self.base.nominal, G.GAME and G.GAME.vegasstuff_chalice or 0, 45 }
        if self.base.suit == "vegasstuff_Pentacles" then
            vars[4], vars[5] = SMODS.get_probability_vars(self, vars[1], 15, "vegasstuff_pentacles")
        end
        localize {
            type = "other",
            key = "vegasstuff_suit_" .. self.base.suit,
            nodes = ui.main,
            vars = vars,
        }
    end
    return ui
end
