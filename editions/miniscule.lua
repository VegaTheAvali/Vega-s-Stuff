local MINISCULE_SCALE = 0.65
local MINISCULE_EDITION_KEY = "e_vegasstuff_miniscule"

_G.VegasStuff = _G.VegasStuff or {}
Vegasstuff = _G.VegasStuff
Vegasstuff.miniscule_scale = MINISCULE_SCALE

function Vegasstuff.is_miniscule_edition(card)
    local edition = card and card.edition
    return edition
        and (
            edition.vegasstuff_miniscule
            or edition.type == "vegasstuff_miniscule"
            or edition.key == MINISCULE_EDITION_KEY
        )
end

function Vegasstuff.center_display_dimensions(card)
    local base_t = card and card.original_T
    if not base_t then
        return nil, nil
    end

    local width = base_t.w
    local height = base_t.h
    local center = card.config and card.config.center

    if center then
        if center.display_size and center.display_size.w then
            width = base_t.w * center.display_size.w / 71
        elseif center.pixel_size and center.pixel_size.w then
            width = base_t.w * center.pixel_size.w / 71
        end

        if center.display_size and center.display_size.h then
            height = base_t.h * center.display_size.h / 95
        elseif center.pixel_size and center.pixel_size.h then
            height = base_t.h * center.pixel_size.h / 95
        end
    end

    return width, height
end

function Vegasstuff.apply_miniscule_size(card)
    local base_t = card and card.original_T
    if not (card and card.T and base_t) then
        return
    end

    card.T.w = base_t.w * MINISCULE_SCALE
    card.T.h = base_t.h * MINISCULE_SCALE

    if card.VT then
        card.VT.w = card.T.w
        card.VT.h = card.T.h
    end
end

function Vegasstuff.restore_miniscule_size(card)
    if not (card and card.T) then
        return
    end

    local width, height = Vegasstuff.center_display_dimensions(card)
    if not (width and height) then
        return
    end

    card.T.w = width
    card.T.h = height

    if card.VT then
        card.VT.w = card.T.w
        card.VT.h = card.T.h
    end
end

SMODS.Edition {
    key = "miniscule",
    shader = "dissolve",
    badge_colour = HEX("a8c7c7"),
    weight = 0,
    in_shop = false,
    apply_to_float = false,
    unlocked = true,
    discovered = true,
    no_collection = true,
    loc_txt = {
        label = "Miniscule",
        name = "Miniscule",
        text = {
            "{C:inactive}Smaller",
            "for no reason{}"
        }
    },
    draw = function(self, card, layer)
    end,
    on_apply = function(card)
        Vegasstuff.apply_miniscule_size(card)
    end,
    on_load = function(card)
        Vegasstuff.apply_miniscule_size(card)
    end,
    on_remove = function(card)
        Vegasstuff.restore_miniscule_size(card)
    end
}
