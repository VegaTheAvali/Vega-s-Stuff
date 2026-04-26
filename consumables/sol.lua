local ASC_POWER_GAIN = 1.25
local ASCENDED_COLOUR = { 14 / 255, 1, 0, 1 }

local function is_cryptid_active()
    local cryptid_mod = SMODS and SMODS.Mods and SMODS.Mods["Cryptid"]
    return cryptid_mod and cryptid_mod.can_load and Cryptid and Cryptid.calculate_ascension_power
end

SMODS.Consumable {
    key = 'sol',
    config = {
        extra = {
            max_level = 20,
            tracker_key = "sol",
            fallback_center_key = "c_vegasstuff_sol"
        }
    },
    set = 'geomancy',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    loc_txt = {
        name = '{C:vegasstuff_name_sol}Sol{}',
        text = {
            [1] = 'Gain +1.25 {V:1}Ascended{} Power',
            [2] = '{C:inactive}(Level #1#/#2#){}'
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'GeomancyCards',
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self)
    end,
    loc_vars = function(self)
        return {
            vars = {
                Vegasstuff.get_geomancy_level_from_extra(self.config.extra),
                self.config.extra.max_level,
                colours = { ASCENDED_COLOUR }
            }
        }
    end,
    can_use = function(self)
        return Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if level >= extra.max_level then
            return
        end

        Vegasstuff.set_geomancy_level_from_extra(extra, level + 1)
        if is_cryptid_active() then
            G.GAME.bonus_asc_power = (G.GAME.bonus_asc_power or 0) + ASC_POWER_GAIN
        else
            G.GAME.vegas_bonus_asc_power = (G.GAME.vegas_bonus_asc_power or 0) + ASC_POWER_GAIN
        end
        Vegasstuff.juice_and_status(used_card, "+Ascension", G.C.GOLD)
    end
}