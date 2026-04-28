local function instance_state()
    if not (G and G.GAME and G.GAME.round_resets) then
        return nil
    end

    local state = G.GAME.vegasstuff_instance
    if state and state.ante ~= G.GAME.round_resets.ante then
        G.GAME.vegasstuff_instance = nil
        return nil
    end

    return state
end

local function instance_copy_value(value)
    if type(value) == "table" then
        return copy_table(value)
    end
    return value
end

local function instance_selected_joker(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.jokers }, card, 1, 1, function(joker)
        return joker
            and joker.ability
            and joker.ability.set == "Joker"
            and not joker.getting_sliced
            and not (Card.no and Card.no(joker, "immutable", true))
    end)
end

local function instance_numeric_values(source)
    local values = {}

    local function collect(tbl)
        for key, value in pairs(tbl or {}) do
            if type(value) == "number" then
                values[key] = value
            elseif type(value) == "table" then
                collect(value)
            end
        end
    end

    collect(source and source.ability)
    return values
end

local function instance_edition(source)
    if not (source and source.edition) then
        return nil
    end

    return copy_table(source.edition)
end

local function instance_stickers(source)
    local stickers = {}

    if not (source and source.ability) then
        return stickers
    end

    stickers.eternal = source.ability.eternal or nil
    stickers.perishable = source.ability.perishable or nil
    stickers.perish_tally = source.ability.perish_tally
    stickers.rental = source.ability.rental or nil

    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do
            if source.ability[key] then
                stickers[key] = instance_copy_value(source.ability[key])
            end
        end
    end

    return stickers
end

local function instance_apply_edition(card, edition)
    if not (card and edition) then
        return
    end

    if edition.key then
        card:set_edition(edition.key, true, true)
    elseif edition.type and G.P_CENTERS["e_" .. edition.type] then
        card:set_edition("e_" .. edition.type, true, true)
    else
        card:set_edition(copy_table(edition), true, true)
    end
end

local function instance_apply_stickers(card, stickers)
    if not (card and card.ability and stickers) then
        return
    end

    if stickers.eternal and card.set_eternal then
        card:set_eternal(true)
    end

    if stickers.perishable and card.set_perishable then
        card:set_perishable(true)
        card.ability.perish_tally = stickers.perish_tally or card.ability.perish_tally
    end

    if stickers.rental and card.set_rental then
        card:set_rental(true)
    end

    if SMODS and SMODS.Sticker and SMODS.Sticker.obj_buffer then
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do
            if stickers[key] then
                if SMODS.Stickers and SMODS.Stickers[key] and SMODS.Stickers[key].apply then
                    SMODS.Stickers[key]:apply(card, instance_copy_value(stickers[key]))
                else
                    card.ability[key] = instance_copy_value(stickers[key])
                end
            end
        end
    end
end

local function instance_apply_values(card, values)
    if not (Cryptid and Cryptid.manipulate and card and values) then
        return
    end

    Cryptid.manipulate(card, {
        bypass_checks = true,
        no_deck_effects = true,
        func = function(value, args, is_big, name)
            if values[name] ~= nil then
                return values[name]
            end
            return value
        end
    })
end

local function instance_apply_to_joker(card)
    local state = instance_state()
    if not (state and card and card.ability and card.ability.set == "Joker") then
        return
    end

    if card.ability.vegasstuff_instance_applied then
        return
    end

    if state.prototype_key and card.config and card.config.center_key == state.prototype_key then
        return
    end

    card.ability.vegasstuff_instance_applied = true
    instance_apply_values(card, state.values)
    instance_apply_edition(card, state.edition)
    instance_apply_stickers(card, state.stickers)

    if card.juice_up then
        card:juice_up(0.3, 0.5)
    end
end

if not _G.vegasstuff_instance_hooks_installed then
    _G.vegasstuff_instance_hooks_installed = true

    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local results = { emplace_ref(self, card, ...) }

        if self == G.jokers then
            instance_apply_to_joker(card)
        end

        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "instance",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #instance_selected_joker(card) == 1
    end,
    use = function(self, card)
        local joker = instance_selected_joker(card)[1]
        if not joker then
            return
        end

        G.GAME.vegasstuff_instance = {
            ante = G.GAME.round_resets.ante,
            prototype_key = joker.config and joker.config.center_key,
            values = instance_numeric_values(joker),
            edition = instance_edition(joker),
            stickers = instance_stickers(joker)
        }

        joker:juice_up(0.3, 0.5)
        G.jokers:unhighlight_all()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 23)
