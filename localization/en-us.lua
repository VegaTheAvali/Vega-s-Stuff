SMODS.Consumable {
	set = "Planet",
	key = "dream_bubble",
	config = { hand_type = "vegasstuff_postage", softlock = true },
	pos = { x = 3, y = 0 },
	atlas = "Planets",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}

SMODS.Consumable {
	set = "Planet",
	key = "skaia",
	config = { hand_type = "vegasstuff_package", softlock = true },
	pos = { x = 1, y = 0 },
	atlas = "Planets",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}

SMODS.Consumable {
	set = "Planet",
	key = "green_moon",
	config = { hand_type = "vegasstuff_mint", softlock = true },
	pos = { x = 2, y = 0 },
	atlas = "Planets",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}

SMODS.Consumable {
	set = "Planet",
	key = "pink_moon",
	config = { hand_type = "vegasstuff_spell", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "Planets",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}

SMODS.Consumable {
	set = "Planet",
	key = "alternia",
	config = { hand_type = "vegasstuff_cauldron", softlock = true },
	pos = { x = 4, y = 0 },
	atlas = "Planets",

	process_loc_text = function(self)
    G.localization.descriptions[self.set][self.key] = {
      text = G.localization.descriptions[self.set].c_mercury.text
    }
	end,

	generate_ui = 0
}
