-- Postage, 5 cards with a sticker?

SMODS.PokerHand {
    key = "postage",
    chips = 90,
    mult = 9,
    l_chips = 25,
    l_mult = 2,
    visible = true,
    above_hand = "Straight Flush",

    example = {
        { 'S_4', true, sticker = 'eternal' },
        { 'H_9', true, sticker = 'perishable' },
        { 'D_J', true, sticker = 'rental' },
        { 'C_6', true, sticker = 'eternal' },
        { 'S_K', true, sticker = 'perishable' },
    },

    evaluate = function(parts, hand)
        local stickered_cards = {}

        for _, card in ipairs(hand) do
            for _, sticker_key in ipairs(SMODS.Sticker.obj_buffer) do
                if card.ability[sticker_key] then
                    table.insert(stickered_cards, card)
                    break
                end
            end
        end

        if #stickered_cards >= 5 then
            return { stickered_cards }
        end

        return {}
    end
}

SMODS.Consumable {
	set = "Planet",
	key = "postage_temp",
	config = { hand_type = "vegasstuff_postage", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "CustomJokers",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}


-- Package, 5 cards with a seal

SMODS.PokerHand {
    key = "package",
    chips = 70,
    mult = 7,
    l_chips = 25,
    l_mult = 2,
    visible = true,
    above_hand = "Four of a Kind",

    example = {
        { 'S_A', true, seal = 'Red' },
        { 'H_Q', true, seal = 'Blue' },
        { 'D_2', true, seal = 'Gold' },
        { 'C_7', true, seal = 'Purple' },
        { 'H_J', true, seal = 'Red' },
    },

    evaluate = function(parts, hand)
        local sealed_cards = {}

        for _, card in ipairs(hand) do
            if card.seal then
                table.insert(sealed_cards, card)
            end
        end

        if #sealed_cards >= 5 then
            return { sealed_cards }
        end

        return {}
    end
}


SMODS.Consumable {
	set = "Planet",
	key = "package_temp",
	config = { hand_type = "vegasstuff_package", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "CustomJokers",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}


-- Mint, 5 cards with an edition. 

SMODS.PokerHand {
    key = "mint",
    chips = 80,
    mult = 8,
    l_chips = 25,
    l_mult = 2,
    visible = true,
    above_hand = "vegasstuff_package",

    example = {
        { 'S_3', true, edition = 'e_foil' },
        { 'H_8', true, edition = 'e_holo' },
        { 'D_K', true, edition = 'e_polychrome' },
        { 'C_5', true, edition = 'e_foil' },
        { 'S_T', true, edition = 'e_holo' },
    },

    evaluate = function(parts, hand)
        local editioned_cards = {}

        for _, card in ipairs(hand) do
            if card.edition then
                table.insert(editioned_cards, card)
            end
        end

        if #editioned_cards >= 5 then
            return { editioned_cards }
        end

        return {}
    end
}

SMODS.Consumable {
	set = "Planet",
	key = "mint_temp",
	config = { hand_type = "vegasstuff_mint", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "CustomJokers",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}


-- Spell, 5 enhanced cards

SMODS.PokerHand {
    key = "spell",
    chips = 60,
    mult = 6,
    l_chips = 20,
    l_mult = 2,
    visible = true,
    above_hand = "Full House",

    example = {
        { 'C_4', true, enhancement = 'm_bonus' },
        { 'D_9', true, enhancement = 'm_mult' },
        { 'H_K', true, enhancement = 'm_lucky' },
        { 'S_6', true, enhancement = 'm_glass' },
        { 'C_A', true, enhancement = 'm_steel' },
    },

    evaluate = function(parts, hand)
        local enhanced_cards = {}

        for _, card in ipairs(hand) do
            if card.config.center.set == 'Enhanced' then
                table.insert(enhanced_cards, card)
            end
        end

        if #enhanced_cards >= 5 then
            return { enhanced_cards }
        end

        return {}
    end
}

SMODS.Consumable {
	set = "Planet",
	key = "spelltemp",
	config = { hand_type = "vegasstuff_spell", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "CustomJokers",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}

-- Cauldron at least 4 modified cards

SMODS.PokerHand {
    key = "cauldron",
    chips = 100,
    mult = 10,
    l_chips = 30,
    l_mult = 3,
    visible = true,
    above_hand = "vegasstuff_postage",

    example = {
        { 'H_2', true, enhancement = 'm_bonus' },
        { 'D_8', true, seal = 'Blue' },
        { 'S_Q', true, edition = 'e_foil' },
        { 'C_5', true, sticker = 'rental' },
    },

    evaluate = function(parts, hand)
        local found = {}

        for _, card in ipairs(hand) do
            local modification
            local count = 0

            if card.config.center.set == 'Enhanced' then
                modification = 'enhancement'
                count = count + 1
            end

            if card.seal then
                modification = 'seal'
                count = count + 1
            end

            if card.edition then
                modification = 'edition'
                count = count + 1
            end

            for _, sticker_key in ipairs(SMODS.Sticker.obj_buffer) do
                if card.ability[sticker_key] then
                    modification = 'sticker'
                    count = count + 1
                    break
                end
            end

            if count == 1 and not found[modification] then
                found[modification] = card
            end
        end

        if found.enhancement
            and found.seal
            and found.edition
            and found.sticker then
            return {{
                found.enhancement,
                found.seal,
                found.edition,
                found.sticker
            }}
        end

        return {}
    end
}

SMODS.Consumable {
	set = "Planet",
	key = "cauldron_temp",
	config = { hand_type = "vegasstuff_cauldron", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "CustomJokers",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}