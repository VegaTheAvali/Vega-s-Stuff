_G.VegasStuff = _G.VegasStuff or {}
_G.VegasStuff.Boric = _G.VegasStuff.Boric or {}
_G.VegasStuff.Boric._applied_bonus = _G.VegasStuff.Boric._applied_bonus or 0

function _G.VegasStuff.Boric.is_boric_card(card)
    local ed = card and card.edition
    return ed and (ed.vegasstuff_boric or ed.type == "vegasstuff_boric" or ed.key == "e_vegasstuff_boric")
end

function _G.VegasStuff.Boric.count_highlighted_boric(cardarea)
    if not (cardarea and cardarea.highlighted) then
        return 0
    end

    local count = 0
    for _, highlighted_card in ipairs(cardarea.highlighted) do
        if _G.VegasStuff.Boric.is_boric_card(highlighted_card) then
            count = count + 1
        end
    end

    return count
end

function _G.VegasStuff.Boric.apply_bonus(target_bonus)
    if not (G and G.GAME and G.hand and SMODS and SMODS.change_play_limit and SMODS.change_discard_limit) then
        return false
    end

    local delta = target_bonus - (_G.VegasStuff.Boric._applied_bonus or 0)
    if delta ~= 0 then
        SMODS.change_play_limit(delta)
        SMODS.change_discard_limit(delta)
        _G.VegasStuff.Boric._applied_bonus = target_bonus
    end

    return true
end

function _G.VegasStuff.Boric.refresh_bonus()
    if not (G and G.hand) then
        return
    end
    _G.VegasStuff.Boric.apply_bonus(_G.VegasStuff.Boric.count_highlighted_boric(G.hand))
end

if not _G.VegasStuff.Boric._highlight_hooked then
    _G.VegasStuff.Boric._highlight_hooked = true
    local boric_add_to_highlighted_ref = CardArea.add_to_highlighted
    local boric_remove_from_highlighted_ref = CardArea.remove_from_highlighted
    local boric_unhighlight_all_ref = CardArea.unhighlight_all

    function CardArea:add_to_highlighted(card, silent)
        local temp_raised = false
        if self == G.hand and _G.VegasStuff.Boric.is_boric_card(card) and self.config and self.config.highlighted_limit and #self.highlighted >= self.config.highlighted_limit then
            _G.VegasStuff.Boric.apply_bonus((_G.VegasStuff.Boric._applied_bonus or 0) + 1)
            temp_raised = true
        end

        local results = { boric_add_to_highlighted_ref(self, card, silent) }
        if self == G.hand or temp_raised then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end

    function CardArea:remove_from_highlighted(card, forced)
        local results = { boric_remove_from_highlighted_ref(self, card, forced) }
        if self == G.hand then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end

    function CardArea:unhighlight_all()
        local results = { boric_unhighlight_all_ref(self) }
        if self == G.hand then
            _G.VegasStuff.Boric.refresh_bonus()
        end
        return unpack(results)
    end
end

SMODS.Edition {
    key = 'boric',

    -- Use the Boric custom shader
    shader = "boric",

    in_shop = true,
    badge_colour = HEX('22BF33'),
    apply_to_float = false,
    disable_shadow = false,
    disable_base_shader = false,

    loc_txt = {
        label = 'Boric',
        name = 'Boric',
        text = {
            [1] = "While {C:attention}highlighted{}, gives",
            [2] = "{C:attention}+1{} play and discard {C:attention}selection limit{}"
        }
    },
    -- Custom draw path: avoid default _send payload for this shader.
    draw = function(self, card, layer)
        local send = card and card.ARGS and card.ARGS.send_to_shader or nil
        if card and card.children and card.children.center then
            card.children.center:draw_shader(self.shader, nil, send)
        end
        if card and card.children and card.children.front and not card:should_hide_front() then
            card.children.front:draw_shader(self.shader, nil, send)
        end
    end,

    unlocked = true,
    discovered = true,
    no_collection = false,

    get_weight = function(self)
        return (G and G.GAME and G.GAME.edition_rate or 1) * (self.weight or 1)
    end,
}
