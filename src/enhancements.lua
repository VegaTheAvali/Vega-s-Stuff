-- Enhancements

SMODS.Enhancement {
    key = "miniscule",
    weight = 0,
    display_size = {
        w = 46.15,
        h = 61.75
    },

    

    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = true,
    in_pool = function(self, args)
        return false
    end
}

SMODS.Enhancement{
    key = "wartorn",
    atlas = "CustomEnhancements",
    pos = {x = 0, y = 0},
    weight = 5,

    

    calculate = function(self, card, context)
        if not (context.main_scoring and context.cardarea == G.play) then
            return
        end

        local base_chips = (card.base and card.base.nominal) or 0
        if base_chips == 0 then
            return
        end

        return {
            chip_mod = -base_chips,
            mult = base_chips
        }
    end
}

SMODS.Enhancement{
    key = "anaphase",
    atlas = "CustomEnhancements",
    pos = {x = 6, y = 0},

    config = {
        extra = {
            threshold = 3
        }
    },

    

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.anaphase_plays or 0,
                card.ability.extra.threshold
            }
        }
    end,

    calculate = function(self, card, context)
        if context.before and context.cardarea == G.play then
            for _, played_card in ipairs(context.full_hand) do
                if played_card == card then
                    card.ability.anaphase_plays = card.ability.anaphase_plays or 0
                    card.ability.anaphase_plays = card.ability.anaphase_plays + 1

                    if card.ability.anaphase_plays >= card.ability.extra.threshold then
                        card.ability.anaphase_plays = 0

	                        G.E_MANAGER:add_event(Event({
	                            func = function()
	                                G.playing_card = (G.playing_card or 0) + 1
	                                local copy = copy_card(card, nil, nil, G.playing_card)

	                                if copy then
	                                    copy:set_ability(G.P_CENTERS.c_base)
	                                    copy:add_to_deck()
	                                    table.insert(G.playing_cards, copy)
	                                    G.deck:emplace(copy)
	                                    copy:start_materialize()
	                                    playing_card_joker_effects({ copy })
	                                end

	                                return true
	                            end
	                        }))

                        return {
                            message = "Divide!",
                            colour = G.C.PURPLE
                        }
                    end
                end
            end
        end
    end
}

SMODS.Enhancement{
    key = "dreamy",
    atlas = "CustomEnhancements",
    pos = {x = 2, y = 0},

        config = {
        extra = {
            tarotmult = 2
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.extra.tarotmult
            }
        }
    end,

    

    calculate = function(self, card, context)
        if not (context.main_scoring and context.cardarea == G.play) then
            return
        end

        local usage = (G and G.GAME and G.GAME.consumeable_usage_total) or {}
        local tarot_used = usage.tarot or 0
        if tarot_used <= 0 then
            return
        end

        local mult_gain = tarot_used * (card.ability.extra.tarotmult or 0)
        if mult_gain == 0 then
            return
        end

        return {
            mult = mult_gain
        }
    end,

    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5
}

local function duality_reduction_for_id(id)
    if type(id) ~= "number" then
        return 0
    end
    if id == 14 then
        return 11 / 2
    end
    if id >= 10 then
        return 10 / 2
    end
    return id / 2
end

SMODS.Enhancement {
    key = 'duality',
    pos = { x = 3, y = 0 },

    

    atlas = "CustomEnhancements",
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    loc_vars = function(self, info_queue, card)
        if not card then return {vars = {0}} end

        local reduction = duality_reduction_for_id(card:get_id())
        return {vars = {reduction}}
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local reduction = duality_reduction_for_id(card:get_id())
            if reduction <= 0 then
                return
            end

            if G.GAME.blind and G.GAME.blind.chips then
                local blind_multiplier = to_big(1 - (reduction / 100))
                local new_blind = to_big(G.GAME.blind.chips) * blind_multiplier

                if to_big(new_blind) < to_big(1) then
                    new_blind = 1
                end

                G.GAME.blind.chips = Vegasstuff.to_number(new_blind, 1)
            end

            return {
                message = "-"..reduction.."%",
                colour = G.C.BLUE
            }
        end
    end
}

SMODS.Enhancement{
    key = "midas",
    atlas = "CustomEnhancements",
    pos = {x = 4, y = 0},

    config = {
        extra = {
            dollars = 5
        }
    },

    

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.dollars}}
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local midas_count = 0

            for _, c in ipairs(context.full_hand) do
                if c.config.center.key == "m_vegasstuff_midas" then
                    midas_count = midas_count + 1
                end
            end

            return {
                dollars = card.ability.extra.dollars,
                retrigger = midas_count - 1
            }
        end
    end
}

SMODS.Enhancement{
    key = "rusted",
    name = "Rusted",
    atlas = "CustomEnhancements",
    pos = {x = 5, y = 0},

    config = {
        chips = 100,
        held_mult = 5
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.chips,
                self.config.held_mult
            }
        }
    end,

    

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            return {
                chips = self.config.chips
            }
        end

        if context.cardarea == G.hand and context.main_scoring then
            local rusted_in_played = false

            for i = 1, #context.scoring_hand do
                local c = context.scoring_hand[i]

                if SMODS.has_enhancement(c, "rusted") then
                    rusted_in_played = true
                    break
                end
            end

            local result = {
                mult = self.config.held_mult
            }

            if not rusted_in_played then
                if card and card.juice_up then
                    card:juice_up(0.4, 0.4)
                end

                result.retrigger = true
            end

            return result
        end
    end
}

SMODS.Enhancement {
    key = "toxin",
    pos = {x = 1, y = 1},

    config = {
        extra = {
            plays = 5,
            xmult = 5
        }
    },

    

    atlas = "CustomEnhancements",
    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.extra.xmult,
                card.ability.extra.plays or self.config.extra.plays
            }
        }
    end,

    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            card.ability.extra.plays = (card.ability.extra.plays or self.config.extra.plays) - 1

            if card.ability.extra.plays <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
            end

            return {
                xmult = self.config.extra.xmult
            }
        end
    end
}

SMODS.Enhancement{
    key = "scoped",
    atlas = "CustomEnhancements",
    pos = {x = 0, y = 1},

    config = {
        extra = {
            xmult_mod = 0.5
        }
    },

    

    loc_vars = function(self, info_queue, card)
        local edition_tally = 0

        if G.jokers and G.jokers.cards then
            for _, joker_card in ipairs(G.jokers.cards) do
                if joker_card.edition then
                    edition_tally = edition_tally + 1
                end
            end
        end

        return {
            vars = {
                self.config.extra.xmult_mod,
                edition_tally * self.config.extra.xmult_mod
            }
        }
    end,

    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    calculate = function(self, card, context)
        if not (context.main_scoring and context.cardarea == G.play) then
            return
        end

        local edition_tally = 0

        if G.jokers and G.jokers.cards then
            for _, joker_card in ipairs(G.jokers.cards) do
                if joker_card.edition then
                    edition_tally = edition_tally + 1
                end
            end
        end

        local total_xmult = edition_tally * self.config.extra.xmult_mod
        if total_xmult <= 0 then
            return
        end

        return {
            xmult = total_xmult
        }
    end
}

SMODS.Enhancement{
    key = "tapered",
    atlas = "CustomEnhancements",
    pos = {x = 4, y = 1},

    config = {},

    

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            if #context.full_hand == 1 then
                local played_card = context.full_hand[1]

                if played_card.config.center.key == "m_vegasstuff_tapered" then
                    for _, hand_card in ipairs(G.hand.cards) do
                        if not hand_card.seal then
                            local seals = {
                                "Gold",
                                "Red",
                                "Blue",
                                "Purple"
                            }

                            local chosen_seal = pseudorandom_element(seals, pseudoseed("tapered"))
                            hand_card:set_seal(chosen_seal, true)
                        end
                    end

                    return {
                        message = "Tapered!",
                        colour = G.C.ATTENTION
                    }
                end
            end
        end
    end
}

SMODS.Enhancement{
    key = "soggy",
    atlas = "CustomEnhancements",
    pos = {x = 2, y = 1},

    config = {
        extra = {
            pluschip = 10,
            minuschip = 10,
            bonus_chips = 0
        }
    },

    

    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    loc_vars = function(self, info_queue, card)
        local current_bonus = self.config.extra.bonus_chips
        local min_bonus = 0

        if card and card.ability and card.ability.extra then
            current_bonus = card.ability.extra.bonus_chips or current_bonus
        end

        if card and card.base and card.base.nominal then
            min_bonus = card.base.nominal
        end

        return {
            vars = {
                self.config.extra.pluschip,
                self.config.extra.minuschip,
                current_bonus,
                min_bonus
            }
        }
    end,

    calculate = function(self, card, context)
        local base_chips = (card.base and card.base.nominal) or 0
        card.ability.extra.bonus_chips = card.ability.extra.bonus_chips or base_chips

        if context.main_scoring and context.cardarea == G.play then
            card.ability.extra.bonus_chips = card.ability.extra.bonus_chips + card.ability.extra.pluschip

            return {
                chips = card.ability.extra.bonus_chips
            }
        end

        if context.end_of_round and context.individual and context.cardarea == G.hand and context.other_card == card then
            local previous_bonus = card.ability.extra.bonus_chips
            card.ability.extra.bonus_chips = math.max(
                base_chips,
                previous_bonus - card.ability.extra.minuschip
            )

            if card.ability.extra.bonus_chips < previous_bonus then
                return {
                    message = "Soggy",
                    colour = G.C.BLUE
                }
            end
        end
    end
}

SMODS.Enhancement{
    key = "stitched",
    name = "Stitched",
    atlas = "CustomEnhancements",
    pos = {x = 3, y = 1},

    config = {
        chip_multiplier = 4
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.chip_multiplier
            }
        }
    end,

    

    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local base_chips = card.base.nominal or 0
            local total_chips = base_chips * self.config.chip_multiplier

            local stitched_count = 0

            for i = 1, #context.scoring_hand do
                local c = context.scoring_hand[i]

                if SMODS.has_enhancement(c, "stitched") then
                    stitched_count = stitched_count + 1
                end
            end

            local retrigger_active = stitched_count >= 2

            if retrigger_active and card and card.juice_up then
                card:juice_up(0.4, 0.4)
            end

            return {
                chips = total_chips,
                retrigger = retrigger_active
            }
        end
    end
}

SMODS.Enhancement{
    key = "creased",
    atlas = "CustomEnhancements",
    pos = {x = 1, y = 0},

    config = {
        extra = {
            hand_size = 1,
            applied_handsize = 0
        }
    },

    

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.config.extra.hand_size
            }
        }
    end,

    any_suit = false,
    replace_base_card = false,
    no_rank = false,
    no_suit = false,
    always_scores = false,
    unlocked = true,
    discovered = true,
    no_collection = false,
    weight = 5,

    add_to_deck = function(self, card, from_debuff)
        card.ability.extra.applied_handsize = card.ability.extra.applied_handsize or 0
    end,

    remove_from_deck = function(self, card, from_debuff)
        local applied_handsize = (card.ability.extra and card.ability.extra.applied_handsize) or 0

        if applied_handsize ~= 0 and G.hand then
            G.hand:change_size(-applied_handsize)
            card.ability.extra.applied_handsize = 0
        end
    end,

    update = function(self, card, dt)
        if not (G and G.hand and card and card.ability and card.ability.extra) then
            return
        end

        local target_handsize = 0
        if card.area == G.hand then
            target_handsize = card.ability.extra.hand_size or 0
        end

        local applied_handsize = card.ability.extra.applied_handsize or 0
        local handsize_delta = target_handsize - applied_handsize

        if handsize_delta ~= 0 then
            G.hand:change_size(handsize_delta)
            card.ability.extra.applied_handsize = target_handsize
        end
    end
}
