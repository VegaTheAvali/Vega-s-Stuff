local function level()
    return Vegasstuff.get_geomancy_level("jupiter")
end

local function selection_bonus(target_level)
    return Vegasstuff.safe_int(Vegasstuff.scaled_geomancy_value(target_level or level()), 0)
end

local function max_level()
    return 5
end

if not _G.vegasstuff_jupiter_open_hooked then
    _G.vegasstuff_jupiter_open_hooked = true
    local card_open_ref = Card.open
    function Card:open(...)
        local out = card_open_ref(self, ...)

        if self and self.ability and self.ability.set == "Booster" and G and G.GAME and G.GAME.pack_choices then
            local current_level = level()
            local bonus = selection_bonus(current_level)
            if current_level > 0 and bonus > 0 then
                local booster_size_mod = G.GAME.modifiers.booster_size_mod or 0
                local pack_size = self.ability.extra or (self.config.center and self.config.center.extra) or 1
                local max_size = math.max(1, pack_size + booster_size_mod)
                if current_level >= max_level() then
                    G.GAME.pack_choices = max_size
                else
                    G.GAME.pack_choices = math.min((G.GAME.pack_choices or 0) + bonus, max_size)
                end
            end
        end

        return out
    end
end

SMODS.Consumable {
    key = "jupiter",
    config = {
        extra = {
            max_level = max_level(),
            tracker_key = "jupiter",
            fallback_center_key = "c_vegasstuff_jupiter"
        }
    },
    set = "geomancy",
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    loc_txt = {
        name = '{C:vegasstuff_name_jupiter}Jupiter{}',
        text = {
            [1] = "{C:attention}Booster Packs{} have",
            [2] = "{C:attention}+#1#{} {C:attention}pack selection{}",
            [3] = "{C:attention}Max level{} lets you take {C:attention}every card{}",
            [4] = "{C:inactive}(Level #2#/#3#){}"
        }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = "GeomancyCards",
    in_pool = function(self)
        return Vegasstuff.can_spawn_geomancy_card(self)
    end,
    loc_vars = function(self)
        local level = Vegasstuff.get_geomancy_level_from_extra(self.config.extra)
        local next_level = math.min(level + 1, self.config.extra.max_level)
        local next_bonus = level >= self.config.extra.max_level and selection_bonus(level) or selection_bonus(next_level)
        return { vars = { next_bonus, level, self.config.extra.max_level } }
    end,
    can_use = function(self)
        return Vegasstuff.geomancy_can_use(self)
    end,
    use = function(self, card, area, copier)
        local used_card = copier or card
        local extra = self.config.extra
        local current_level = Vegasstuff.get_geomancy_level_from_extra(extra)
        if current_level >= extra.max_level then
            return
        end

        local next_level = current_level + 1
        Vegasstuff.set_geomancy_level_from_extra(extra, next_level)
        Vegasstuff.juice_and_status(used_card, "Pack Selection +" .. tostring(selection_bonus(next_level)), G.C.IMPORTANT or G.C.YELLOW)
    end,
}
