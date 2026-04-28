local ROM_MULTIUSE = 5

local function random_rom_consumable()
    if Cryptid and Cryptid.random_consumable then
        return Cryptid.random_consumable("vegasstuff_rom", nil, "c_vegasstuff_rom")
    end
end

Vegasstuff.retro_code_consumable({
    key = "rom",
    loc_txt = {
        name = "://ROM",
        text = {
            "Create a random {C:attention}Consumable{}",
            "with {C:attention}#1#{} uses"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            multiuse = ROM_MULTIUSE
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.multiuse } }
    end,
    can_use = function(self)
        return G
            and G.consumeables
            and G.consumeables.cards
            and G.consumeables.config
            and #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit
    end,
    use = function(self)
        local center = random_rom_consumable()
        if not center then
            return
        end

        local created = create_card("Consumeables", G.consumeables, nil, nil, nil, nil, center.key, "vegasstuff_rom")
        created.ability.cry_multiuse = self.config.extra.multiuse
        created:add_to_deck()
        G.consumeables:emplace(created)
        created:juice_up(0.3, 0.5)
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 11)
