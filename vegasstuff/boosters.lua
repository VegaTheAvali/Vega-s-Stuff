
SMODS.Booster {
    key = 'pack_of_creation',
    loc_txt = {
        name = "Pack of Creation",
        text = {
            [1] = 'Choose up to {C:gold}3{} of {C:gold}3{} selection cards',
            [2] = '{C:inactive}70% chance of{} {C:spectral}pointer{}',
            [3] = '{C:inactive}30% chance of {C:spectral}gateway{}'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    weight = 7.5,
    atlas = "CustomBoosters",
    dependencies = {"Cryptid"},
    pos = { x = 0, y = 0 },
    group_key = "vegasstuff_boosters",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        local weights = {
            0.7,
            0.3
        }
        local total_weight = 0
        for _, weight in ipairs(weights) do
            total_weight = total_weight + weight
        end
        local random_value = pseudorandom('vegasstuff_pack_of_creation_card') * total_weight
        local cumulative_weight = 0
        local selected_index = 1
        for j, weight in ipairs(weights) do
            cumulative_weight = cumulative_weight + weight
            if random_value <= cumulative_weight then
                selected_index = j
                break
            end
        end
        if selected_index == 1 then
            return {
                key = "c_cry_pointer",
                set = "Spectral",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_pack_of_creation"
            }
        elseif selected_index == 2 then
            return {
                key = "c_cry_gateway",
                set = "Spectral",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_pack_of_creation"
            }
        end
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("0082f9"))
        ease_background_colour({ new_colour = HEX('0082f9'), special_colour = HEX("cdbb53"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'omega_pack',
    loc_txt = {
        name = "Omega Pack",
        text = {
            [1] = 'A pack with Omega cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    atlas = "CustomBoosters",
    dependencies = {"Polterwor"},
    pos = { x = 1, y = 0 },
    soul_pos = { x = 2, y = 0 },
    group_key = "vegasstuff_boosters",
    draw_hand = true,
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        local selected_index = pseudorandom('vegasstuff_omega_pack_card', 1, 19)
        if selected_index == 1 then
            return {
                key = "black_hole_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 2 then
            return {
                key = "ankh_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 3 then
            return {
                key = "aura_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 4 then
            return {
                key = "soul_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 5 then
            return {
                key = "cryptid_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 6 then
            return {
                key = "ectoplasm_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 7 then
            return {
                key = "familiar_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 8 then
            return {
                key = "grim_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 9 then
            return {
                key = "hex_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 10 then
            return {
                key = "immolate_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 11 then
            return {
                key = "incantation_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 12 then
            return {
                key = "ouija_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 13 then
            return {
                key = "sigil_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 14 then
            return {
                key = "wraith_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 15 then
            return {
                key = "fool_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 16 then
            return {
                key = "high_priestess_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 17 then
            return {
                key = "emperor_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 18 then
            return {
                key = "hermit_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        elseif selected_index == 19 then
            return {
                key = "wheel_of_fortune_omega",
                set = "Tarot",
                area = G.pack_cards,
                skip_materialize = true,
                soulable = true,
                key_append = "vegasstuff_omega_pack"
            }
        end
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'zodiac_pack',
    loc_txt = {
        name = "Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}3{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    atlas = "ZodiacPacks",
    pos = { x = 0, y = 0 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_zodiac_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'zodiacpack2',
    loc_txt = {
        name = "Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}3{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    atlas = "ZodiacPacks",
    pos = { x = 1, y = 0 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_zodiacpack2"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'zodiacpack3',
    loc_txt = {
        name = "Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}3{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    atlas = "ZodiacPacks",
    pos = { x = 2, y = 0 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_zodiacpack3"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'zodiacpack4',
    loc_txt = {
        name = "Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}3{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 3, choose = 1 },
    atlas = "ZodiacPacks",
    pos = { x = 3, y = 0 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_zodiacpack4"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'jumbo_zodiac_pack',
    loc_txt = {
        name = "Jumbo Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}5{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 5, choose = 1 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 0, y = 1 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_jumbo_zodiac_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'jumbozodiacpack2',
    loc_txt = {
        name = "Jumbo Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}5{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 5, choose = 1 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 1, y = 1 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_jumbozodiacpack2"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'mega_zodiac_pack',
    loc_txt = {
        name = "Mega Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}2{} of {C:attention}5{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 5, choose = 2 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 2, y = 1 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_mega_zodiac_pack"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}


SMODS.Booster {
    key = 'megazodiacpack2',
    loc_txt = {
        name = "Mega Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}2{} of {C:attention}5{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 5, choose = 2 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 3, y = 1 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_megazodiacpack2"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'minizodiacpack',
    loc_txt = {
        name = "Mini Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}2{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 2, choose = 1 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 0, y = 2 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_megazodiacpack2"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}

SMODS.Booster {
    key = 'minizodiacpack2',
    loc_txt = {
        name = "Mini Zodiac Pack",
        text = {
            [1] = 'Choose up to {C:attention}1{} of {C:attention}2{} Zodiac cards'
        },
        group_name = "vegasstuff_boosters"
    },
    config = { extra = 2, choose = 1 },
    cost = 6,
    atlas = "ZodiacPacks",
    pos = { x = 1, y = 2 },
    group_key = "vegasstuff_boosters",
    select_card = "consumeables",
    discovered = true,
    loc_vars = function(self, info_queue, card)
        local cfg = (card and card.ability) or self.config
        return {
            vars = { cfg.choose, cfg.extra }
        }
    end,
    create_card = function(self, card, i)
        return {
            set = "zodiac",
            area = G.pack_cards,
            skip_materialize = true,
            soulable = true,
            key_append = "vegasstuff_megazodiacpack2"
        }
    end,
    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, HEX("49006d"))
        ease_background_colour({ new_colour = HEX('49006d'), special_colour = HEX("d178ff"), contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.WHITE, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.GOLD, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
}
