local MINISCULE_STAKE_EDITION = "e_vegasstuff_miniscule"
local MINISCULE_STAKE_MODIFIER = "vegasstuff_miniscule_stake"

local card_set_ability_ref = _G.vegasstuff_miniscule_stake_set_ability_ref
local card_set_edition_ref = _G.vegasstuff_miniscule_stake_set_edition_ref

local function miniscule_stake_active()
    return G
        and G.GAME
        and G.GAME.modifiers
        and G.GAME.modifiers[MINISCULE_STAKE_MODIFIER]
end

local function miniscule_stake_edition()
    return G and G.P_CENTERS and G.P_CENTERS[MINISCULE_STAKE_EDITION]
end

local function miniscule_stake_is_playing_card(card)
    local set = card and card.ability and card.ability.set
    return card and (card.playing_card or set == "Default" or set == "Enhanced")
end

local function miniscule_stake_has_edition(card)
    return Vegasstuff and Vegasstuff.is_miniscule_edition and Vegasstuff.is_miniscule_edition(card)
end

local function miniscule_stake_apply(card)
    if not (
        miniscule_stake_active()
        and miniscule_stake_edition()
        and miniscule_stake_is_playing_card(card)
        and card.set_edition
    ) then
        return
    end

    if miniscule_stake_has_edition(card) then
        if Vegasstuff and Vegasstuff.apply_miniscule_size then
            Vegasstuff.apply_miniscule_size(card)
        end
        return
    end

    local set_edition = card_set_edition_ref or _G.vegasstuff_miniscule_stake_set_edition_ref or Card.set_edition
    set_edition(card, MINISCULE_STAKE_EDITION, true, true)
end

local function miniscule_stake_apply_to_deck()
    if not (G and G.playing_cards) then
        return
    end

    for _, playing_card in ipairs(G.playing_cards) do
        miniscule_stake_apply(playing_card)
    end
end

local function miniscule_stake_queue_deck_update()
    if not miniscule_stake_active() then
        return
    end

    if G and G.E_MANAGER then
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0,
            func = function()
                miniscule_stake_apply_to_deck()
                return true
            end
        }))
        return
    end

    miniscule_stake_apply_to_deck()
end

if Card and Card.set_ability and not _G.vegasstuff_miniscule_stake_set_ability_hooked then
    _G.vegasstuff_miniscule_stake_set_ability_hooked = true
    card_set_ability_ref = Card.set_ability
    _G.vegasstuff_miniscule_stake_set_ability_ref = card_set_ability_ref

    function Card:set_ability(center, initial, delay_sprites)
        local ret = card_set_ability_ref(self, center, initial, delay_sprites)
        miniscule_stake_apply(self)
        return ret
    end
end

if Card and Card.set_edition and not _G.vegasstuff_miniscule_stake_set_edition_hooked then
    _G.vegasstuff_miniscule_stake_set_edition_hooked = true
    card_set_edition_ref = Card.set_edition
    _G.vegasstuff_miniscule_stake_set_edition_ref = card_set_edition_ref

    function Card:set_edition(edition, immediate, silent, delay)
        local ret = card_set_edition_ref(self, edition, immediate, silent, delay)
        miniscule_stake_apply(self)
        return ret
    end
end

if Card and Card.add_to_deck and not _G.vegasstuff_miniscule_stake_add_to_deck_hooked then
    _G.vegasstuff_miniscule_stake_add_to_deck_hooked = true
    local card_add_to_deck_ref = Card.add_to_deck

    function Card:add_to_deck(from_debuff)
        local ret = card_add_to_deck_ref(self, from_debuff)
        miniscule_stake_apply(self)
        return ret
    end
end

if Game and Game.start_run and not _G.vegasstuff_miniscule_stake_start_run_hooked then
    _G.vegasstuff_miniscule_stake_start_run_hooked = true
    local game_start_run_ref = Game.start_run

    function Game:start_run(args)
        local ret = game_start_run_ref(self, args)
        miniscule_stake_queue_deck_update()
        return ret
    end
end

local function miniscule_stake_loc()
    return G
        and G.localization
        and G.localization.descriptions
        and G.localization.descriptions.Stake
        and G.localization.descriptions.Stake.stake_vegasstuff_stake
        or {}
end

SMODS.Stake {
    key = "stake",
    loc_txt = miniscule_stake_loc(),
    applied_stakes = { "gold" },
    above_stake = "gold",
    prefix_config = {
        applied_stakes = { mod = false },
        above_stake = { mod = false }
    },
    atlas = "vegasstuff_stake",
    pos = { x = 0, y = 0 },
    colour = HEX("ff9352"),
    modifiers = function()
        G.GAME.modifiers = G.GAME.modifiers or {}
        G.GAME.modifiers[MINISCULE_STAKE_MODIFIER] = true
    end
}
