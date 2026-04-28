local TYPEDEF_MAX_CARDS = 5

local function typedef_state()
    if not (G and G.GAME and G.GAME.round_resets) then
        return nil
    end

    G.GAME.vegasstuff_typedef = G.GAME.vegasstuff_typedef or {
        ante = G.GAME.round_resets.ante,
        next_id = 1
    }

    if G.GAME.vegasstuff_typedef.ante ~= G.GAME.round_resets.ante then
        G.GAME.vegasstuff_typedef = {
            ante = G.GAME.round_resets.ante,
            next_id = 1
        }

        if G.playing_cards then
            for _, card in ipairs(G.playing_cards) do
                if card.ability then
                    card.ability.vegasstuff_typedef = nil
                end
            end
        end
    end

    return G.GAME.vegasstuff_typedef
end

local function typedef_selected_cards(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards({ G.hand }, card, 1, TYPEDEF_MAX_CARDS, function(target)
        return target and target.playing_card and target.ability
    end)
end

local function typedef_cards_in_group(group_id, source)
    local cards = {}

    if G and G.playing_cards then
        for _, card in ipairs(G.playing_cards) do
            if card ~= source
                and card.ability
                and card.ability.vegasstuff_typedef == group_id
                and not card.destroyed
                and not card.shattered
            then
                cards[#cards + 1] = card
            end
        end
    end

    return cards
end

local function typedef_copy_context(context)
    local copy = {}
    for key, value in pairs(context or {}) do
        copy[key] = value
    end
    copy.cardarea = G.play
    copy.vegasstuff_typedef_phantom = true
    return copy
end

if not _G.vegasstuff_typedef_hooks_installed then
    _G.vegasstuff_typedef_hooks_installed = true

    local score_card_ref = SMODS.score_card
    function SMODS.score_card(card, context)
        score_card_ref(card, context)

        typedef_state()
        if not (card and card.ability and card.ability.vegasstuff_typedef) then
            return
        end

        if not (context and context.cardarea == G.play and not context.vegasstuff_typedef_phantom) then
            return
        end

        local group_cards = typedef_cards_in_group(card.ability.vegasstuff_typedef, card)
        for _, phantom_card in ipairs(group_cards) do
            score_card_ref(phantom_card, typedef_copy_context(context))
            if phantom_card.juice_up then
                phantom_card:juice_up(0.15, 0.25)
            end
        end
    end
end

Vegasstuff.retro_code_consumable({
    key = "typedef",
    loc_txt = {
        name = "://TYPEDEF",
        text = {
            "Select up to {C:attention}#1#{} {C:attention}playing cards{}",
            "Until end of {C:attention}Ante{}, they become",
            "a declared {C:green}type{}",
            "When one scores, every other {C:attention}card{}",
            "of that type scores from {C:attention}anywhere{}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            max_cards = TYPEDEF_MAX_CARDS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.max_cards } }
    end,
    can_use = function(self, card)
        return #typedef_selected_cards(card) > 0
    end,
    use = function(self, card)
        local state = typedef_state()
        local cards = typedef_selected_cards(card)
        if not (state and #cards > 0) then
            return
        end

        local group_id = state.next_id
        state.next_id = group_id + 1

        for _, selected in ipairs(cards) do
            selected.ability.vegasstuff_typedef = group_id
            selected:juice_up(0.3, 0.5)
        end

        if G.hand then
            G.hand:unhighlight_all()
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 22)
