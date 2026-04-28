local UNLINK_MULTIUSE = 999999

local function unlink_areas()
    local areas = {}
    if G.hand then
        areas[#areas + 1] = G.hand
    end
    if G.jokers then
        areas[#areas + 1] = G.jokers
    end
    if G.consumeables then
        areas[#areas + 1] = G.consumeables
    end
    if G.pack_cards then
        areas[#areas + 1] = G.pack_cards
    end
    return areas
end

local function unlink_selected_card(card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return {}
    end

    return Cryptid.get_highlighted_cards(unlink_areas(), card, 1, 1, function(target)
        return target and target.ability and not target.ability.vegasstuff_unlinked
    end)
end

local function unlink_consumable_room()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return G.consumeables.config.card_limit - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0)
end

local function unlink_random_retro_code_key(excluded_key)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= excluded_key and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_unlink_retro"))
end

local function unlink_create_random_retro_code()
    if unlink_consumable_room() <= 0 then
        return nil
    end

    local key = unlink_random_retro_code_key("c_vegasstuff_unlink")
    if not key then
        return nil
    end

    local created = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })

    if created then
        created:set_edition({ negative = true }, true, true)
        created:juice_up(0.3, 0.5)
    end

    return created
end

local function unlink_each_owned_card(callback)
    local areas = {}
    if G and G.hand then
        areas[#areas + 1] = G.hand
    end
    if G and G.play then
        areas[#areas + 1] = G.play
    end
    if G and G.discard then
        areas[#areas + 1] = G.discard
    end
    if G and G.jokers then
        areas[#areas + 1] = G.jokers
    end
    if G and G.consumeables then
        areas[#areas + 1] = G.consumeables
    end

    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                callback(card)
            end
        end
    end

    if G and G.playing_cards then
        for _, card in ipairs(G.playing_cards) do
            callback(card)
        end
    end
end

local function unlink_count_cards()
    local seen = {}
    local count = 0

    unlink_each_owned_card(function(card)
        if card and card.ability and card.ability.vegasstuff_unlinked and not seen[card] then
            seen[card] = true
            count = count + 1
        end
    end)

    return count
end

local function unlink_check_bonus()
    if not (G and G.GAME) then
        return
    end

    local count = unlink_count_cards()
    local threshold = math.floor(count / 3)
    G.GAME.vegasstuff_unlink_bonus_count = G.GAME.vegasstuff_unlink_bonus_count or 0

    while G.GAME.vegasstuff_unlink_bonus_count < threshold do
        if not unlink_create_random_retro_code() then
            break
        end
        G.GAME.vegasstuff_unlink_bonus_count = G.GAME.vegasstuff_unlink_bonus_count + 1
    end
end

local function unlink_mark_card(target)
    target.ability.vegasstuff_unlinked = true

    if target.playing_card then
        target.ability.vegasstuff_unlinked_playing = true
        if target.set_debuff then
            target:set_debuff(false)
        else
            target.debuff = false
        end
    elseif target.area == G.jokers then
        target.ability.vegasstuff_unlinked_joker = true
        if not target.ability.vegasstuff_unlinked_slot then
            target.ability.vegasstuff_unlinked_slot = true
            if G.jokers and G.jokers.config then
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
            end
        end
    elseif target.area == G.consumeables or target.area == G.pack_cards then
        target.ability.vegasstuff_unlinked_consumable = true
        target.ability.cry_multiuse = math.max(target.ability.cry_multiuse or 1, UNLINK_MULTIUSE)
    end

    target:juice_up(0.3, 0.5)
    unlink_check_bonus()
end

local function unlink_clear_highlights()
    local areas = unlink_areas()
    for _, area in ipairs(areas) do
        if area.unhighlight_all then
            area:unhighlight_all()
        end
    end
end

if not _G.vegasstuff_unlink_hooks_installed then
    _G.vegasstuff_unlink_hooks_installed = true

    local always_scores_ref = SMODS.always_scores
    function SMODS.always_scores(card, ...)
        if card and card.ability and card.ability.vegasstuff_unlinked_playing then
            return true
        end
        return always_scores_ref(card, ...)
    end

    local is_suit_ref = Card.is_suit
    function Card:is_suit(suit, bypass_debuff, flush_calc)
        if self.ability and self.ability.vegasstuff_unlinked_playing then
            return false
        end
        return is_suit_ref(self, suit, bypass_debuff, flush_calc)
    end

    local is_face_ref = Card.is_face
    function Card:is_face(from_boss)
        if self.ability and self.ability.vegasstuff_unlinked_playing then
            return false
        end
        return is_face_ref(self, from_boss)
    end

    local get_id_ref = Card.get_id
    function Card:get_id(...)
        if self.ability and self.ability.vegasstuff_unlinked_playing then
            return 0
        end
        return get_id_ref(self, ...)
    end

    local debuff_card_ref = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        local results = { debuff_card_ref(self, card, from_blind) }
        if card and card.ability and card.ability.vegasstuff_unlinked_playing then
            if card.set_debuff then
                card:set_debuff(false)
            else
                card.debuff = false
            end
        end
        return (table.unpack or unpack)(results)
    end

    local use_consumeable_ref = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local was_unlinked = self.ability and self.ability.vegasstuff_unlinked_consumable
        local results = { use_consumeable_ref(self, area, copier) }

        if was_unlinked then
            unlink_create_random_retro_code()
            unlink_check_bonus()
        end

        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "unlink",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function(self, card)
        return #unlink_selected_card(card) == 1
    end,
    use = function(self, card)
        local selected = unlink_selected_card(card)[1]
        if not selected then
            return
        end

        unlink_mark_card(selected)
        unlink_clear_highlights()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 30)
