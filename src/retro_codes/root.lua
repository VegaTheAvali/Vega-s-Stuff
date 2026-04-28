local ROOT_HANDS = 99
local ROOT_DISCARDS = 99
local ROOT_HAND_SIZE = 5
local ROOT_JOKER_SLOTS = 5
local ROOT_CONSUMABLE_SLOTS = 12
local ROOT_PACK_BONUS = 5
local ROOT_VALUE_MULT = 10
local ROOT_FLAT_VALUE = 777
local ROOT_TAG_LIMIT = 12
local ROOT_CUSTOM_BUTTON_LIMIT = 6

local function root_state()
    if not (G and G.GAME) then
        return nil
    end

    G.GAME.vegasstuff_root = G.GAME.vegasstuff_root or {
        enabled = false,
        level = 0,
        retro_uses = 0
    }

    if G.GAME.vegasstuff_root.enabled and not G.GAME.vegasstuff_root.kernel_enabled then
        G.GAME.vegasstuff_root.enabled = false
    end

    return G.GAME.vegasstuff_root
end

local function root_enabled()
    local state = G and G.GAME and G.GAME.vegasstuff_root
    return state and state.enabled and state.kernel_enabled
end

local function root_center_set(card)
    return card and card.config and card.config.center and card.config.center.set
end

local function root_ability_set(card)
    return card and card.ability and card.ability.set
end

local function root_is_playing_card(card)
    local set = root_ability_set(card) or root_center_set(card)
    return card and (card.playing_card or set == "Default" or set == "Enhanced")
end

local function root_is_joker(card)
    local set = root_ability_set(card) or root_center_set(card)
    return set == "Joker" or card.area == G.jokers or card.area == G.shop_jokers
end

local function root_is_consumable(card)
    local set = root_ability_set(card) or root_center_set(card)
    return card and card.ability and (card.ability.consumeable or set == "Tarot" or set == "Planet" or set == "Spectral" or set == "Code" or set == "geomancy" or set == "zodiac" or set == Vegasstuff.RETRO_CODE_SET)
end

local function root_is_shop_card(card)
    return card and (card.area == G.shop_jokers or card.area == G.shop_booster or card.area == G.shop_vouchers)
end

local function root_expand_area(area, amount)
    if area and area.config and area.config.card_limit then
        area.config.card_limit = math.max(area.config.card_limit, #area.cards + amount)
    end
end

local function root_zero_cost(card)
    if not card then
        return
    end

    card.cost = 0
    card.sell_cost = math.max(card.sell_cost or 0, 0)
    if card.ability then
        card.ability.couponed = true
    end
end

local function root_apply_memory(card)
    local state = root_state()
    local memory = state and state.memory
    if not (card and card.ability and memory) then
        return
    end

    if memory.edition then
        card:set_edition(copy_table(memory.edition), true, true)
    end

    if memory.seal and card.set_seal then
        card:set_seal(memory.seal, true, true)
    end

    if root_is_playing_card(card) and memory.playing_center and G.P_CENTERS[memory.playing_center] then
        card:set_ability(G.P_CENTERS[memory.playing_center])
    end
end

local function root_apply_card(card)
    if not (card and card.ability) then
        return
    end

    if card.ability.vegasstuff_rooted then
        if root_is_shop_card(card) then
            root_zero_cost(card)
        end
        return
    end

    card.ability.vegasstuff_rooted = true
    root_apply_memory(card)

    if root_is_playing_card(card) then
        card.ability.cry_rigged = true
        card.ability.cry_global_sticker = true
        if card.set_seal then
            card:set_seal("Red", true, true)
        end
        card:set_edition({ polychrome = true }, true, true)
        if card.set_debuff then
            card:set_debuff(false)
        else
            card.debuff = false
        end
    elseif root_is_joker(card) then
        card:set_edition({ negative = true }, true, true)
        if Cryptid and Cryptid.manipulate then
            Cryptid.manipulate(card, {
                type = "X",
                value = ROOT_VALUE_MULT,
                bypass_checks = true,
                no_deck_effects = true
            })
            Cryptid.manipulate(card, {
                type = "+",
                value = ROOT_FLAT_VALUE,
                bypass_checks = true,
                no_deck_effects = true
            })
        end
        if card.ability then
            card.ability.eternal = nil
            card.ability.perishable = nil
            card.ability.rental = nil
            card.ability.cry_absolute = true
        end
    elseif root_is_consumable(card) then
        card.ability.cry_multiuse = math.max(card.ability.cry_multiuse or 1, 999)
        if card.set_edition then
            card:set_edition({ negative = true }, true, true)
        end
    end

    if root_is_shop_card(card) then
        root_zero_cost(card)
    end

    if card.juice_up then
        card:juice_up(0.2, 0.35)
    end
end

local function root_each_card(callback)
    local seen = {}
    local areas = {}

    if G.hand then areas[#areas + 1] = G.hand end
    if G.deck then areas[#areas + 1] = G.deck end
    if G.discard then areas[#areas + 1] = G.discard end
    if G.play then areas[#areas + 1] = G.play end
    if G.jokers then areas[#areas + 1] = G.jokers end
    if G.consumeables then areas[#areas + 1] = G.consumeables end
    if G.pack_cards then areas[#areas + 1] = G.pack_cards end
    if G.shop_jokers then areas[#areas + 1] = G.shop_jokers end
    if G.shop_booster then areas[#areas + 1] = G.shop_booster end
    if G.shop_vouchers then areas[#areas + 1] = G.shop_vouchers end

    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                if card and not seen[card] then
                    seen[card] = true
                    callback(card)
                end
            end
        end
    end

    if G.playing_cards then
        for _, card in ipairs(G.playing_cards) do
            if card and not seen[card] then
                seen[card] = true
                callback(card)
            end
        end
    end
end

local function root_apply_existing_cards()
    root_each_card(root_apply_card)
end

local function root_selected_memory_card(root_card)
    if not (Cryptid and Cryptid.get_highlighted_cards) then
        return nil
    end

    local areas = {}
    if G.hand then areas[#areas + 1] = G.hand end
    if G.jokers then areas[#areas + 1] = G.jokers end
    if G.consumeables then areas[#areas + 1] = G.consumeables end
    if G.pack_cards then areas[#areas + 1] = G.pack_cards end
    if G.shop_jokers then areas[#areas + 1] = G.shop_jokers end
    if G.shop_booster then areas[#areas + 1] = G.shop_booster end
    if G.shop_vouchers then areas[#areas + 1] = G.shop_vouchers end

    local selected = Cryptid.get_highlighted_cards(areas, root_card, 1, 1, function(target)
        return target and target.ability and target.config and target.config.center
    end)

    return selected[1]
end

local function root_capture_memory(root_card)
    local selected = root_selected_memory_card(root_card)
    if not selected then
        return
    end

    local state = root_state()
    if not state then
        return
    end

    state.memory = {
        edition = selected.edition and copy_table(selected.edition) or nil,
        seal = selected.seal,
        playing_center = root_is_playing_card(selected) and selected.config and selected.config.center_key or nil
    }
end

local function root_install_slots()
    if G.hand and G.hand.config then
        G.hand.config.card_limit = G.hand.config.card_limit + ROOT_HAND_SIZE
    end
    if G.jokers and G.jokers.config then
        G.jokers.config.card_limit = G.jokers.config.card_limit + ROOT_JOKER_SLOTS
    end
    if G.consumeables and G.consumeables.config then
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + ROOT_CONSUMABLE_SLOTS
    end

    if G.GAME and G.GAME.modifiers then
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + ROOT_PACK_BONUS
        G.GAME.modifiers.booster_size_mod = (G.GAME.modifiers.booster_size_mod or 0) + ROOT_PACK_BONUS
    end

    if G.GAME and G.GAME.round_resets then
        G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) + ROOT_HAND_SIZE
        G.GAME.round_resets.discards = (G.GAME.round_resets.discards or 0) + ROOT_HAND_SIZE
    end
end

local function root_install_resources()
    if not (G and G.GAME and G.GAME.current_round) then
        return
    end

    ease_hands_played(ROOT_HANDS - (G.GAME.current_round.hands_left or 0))
    ease_discard(ROOT_DISCARDS - (G.GAME.current_round.discards_left or 0))
    ease_dollars(999)
end

local function root_break_blind()
    if not (G and G.GAME and G.GAME.blind and G.GAME.blind.chips) then
        return
    end

    G.GAME.blind.chips = 1
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    G.GAME.chips = math.max(1, Vegasstuff.to_number(G.GAME.chips, 0))
    G.GAME.chips_text = number_format(G.GAME.chips)
    if not G.GAME.blind.disabled then
        G.GAME.blind:disable()
    end
end

local function root_retro_code_keys(excluded_key)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local keys = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= excluded_key and not center.no_collection then
                keys[#keys + 1] = center.key
            end
        end
    end

    table.sort(keys)
    return keys
end

local function root_create_retro_code(key)
    if not (key and G and G.consumeables) then
        return nil
    end

    root_expand_area(G.consumeables, 1)
    local created = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })

    if created then
        root_apply_card(created)
        created:juice_up(0.3, 0.5)
    end

    return created
end

local function root_random_retro_code_key()
    local keys = root_retro_code_keys("c_vegasstuff_root")
    if #keys == 0 then
        return nil
    end

    return pseudorandom_element(keys, pseudoseed("vegasstuff_root_retro"))
end

local function root_create_random_retro_code()
    return root_create_retro_code(root_random_retro_code_key())
end

local function root_create_retro_suite()
    local keys = root_retro_code_keys("c_vegasstuff_root")
    root_expand_area(G.consumeables, #keys)

    for _, key in ipairs(keys) do
        root_create_retro_code(key)
    end
end

local function root_add_tag_suite()
    if not (G and G.P_TAGS) then
        return
    end

    local keys = {}
    for key, _ in pairs(G.P_TAGS) do
        keys[#keys + 1] = key
    end
    table.sort(keys)

    for i = 1, math.min(ROOT_TAG_LIMIT, #keys) do
        add_tag(Tag(keys[i]))
    end
end

local function root_duplicate_hand_to_deck()
    if not (G and G.hand and G.hand.cards and G.playing_card) then
        return
    end

    local hand_cards = {}
    for _, card in ipairs(G.hand.cards) do
        hand_cards[#hand_cards + 1] = card
    end

    for _, card in ipairs(hand_cards) do
        if card and root_is_playing_card(card) then
            G.playing_card = (G.playing_card or 0) + 1
            local copy = copy_card(card, nil, nil, G.playing_card)
            copy:add_to_deck()
            table.insert(G.playing_cards, copy)
            G.deck:emplace(copy)
            root_apply_card(copy)
            copy:start_materialize()
        end
    end
end

local function root_reward_tag(blind_on_deck)
    return G
        and G.GAME
        and G.GAME.round_resets
        and G.GAME.round_resets.blind_tags
        and G.GAME.round_resets.blind_tags[blind_on_deck]
end

local function root_add_tag(tag_key)
    if tag_key and G and G.P_TAGS and G.P_TAGS[tag_key] then
        add_tag(Tag(tag_key))
    end
end

local function root_bloat_shop()
    if not root_enabled() then
        return
    end

    if G.GAME and G.GAME.shop then
        G.GAME.shop.joker_max = math.max(G.GAME.shop.joker_max or 0, 6)
    end

    if G.shop_jokers and G.GAME and G.GAME.shop then
        root_expand_area(G.shop_jokers, G.GAME.shop.joker_max - #G.shop_jokers.cards)
        while #G.shop_jokers.cards < G.GAME.shop.joker_max do
            local card = create_card_for_shop(G.shop_jokers)
            root_apply_card(card)
            G.shop_jokers:emplace(card)
        end
    end

    root_apply_existing_cards()
end

local function root_prepare_pack(booster)
    if not (root_enabled() and booster and booster.ability and booster.ability.set == "Booster") then
        return
    end

    local extra = tonumber(booster.ability.extra) or (booster.config and booster.config.center and booster.config.center.config and booster.config.center.config.extra) or 1
    local size = math.max(1, extra + ROOT_PACK_BONUS)
    booster.ability.extra = size
    booster.ability.choose = size
    G.GAME.pack_size = size
    G.GAME.pack_choices = size
end

local function root_phantom_cards()
    local cards = {}
    if not G.playing_cards then
        return cards
    end

    for _, card in ipairs(G.playing_cards) do
        if card
            and card.ability
            and not card.destroyed
            and not card.shattered
            and card.area ~= G.play
        then
            cards[#cards + 1] = card
        end
    end

    return cards
end

local function root_context_copy(context)
    local copy = {}
    for key, value in pairs(context or {}) do
        copy[key] = value
    end

    copy.cardarea = G.play
    copy.vegasstuff_root_phantom = true
    copy.vegasstuff_bootloop_phantom = true
    return copy
end

local function root_score_phantoms(context)
    local state = root_state()
    if not (state and state.enabled and not state.scored_this_play) then
        return
    end

    state.scored_this_play = true
    local score_card_ref = _G.vegasstuff_root_score_card_ref
    if not score_card_ref then
        return
    end

    local ghost_context = root_context_copy(context)
    for _, card in ipairs(root_phantom_cards()) do
        score_card_ref(card, ghost_context)
        if card.juice_up then
            card:juice_up(0.08, 0.12)
        end
    end
end

local function root_cashout_kernel(state)
    if not (state and state.enabled and state.last_blind_reward) then
        return
    end

    local reward = state.last_blind_reward
    state.last_blind_reward = nil

    if reward.dollars and reward.dollars > 0 then
        ease_dollars(reward.dollars * 3)
    end

    for _ = 1, 3 do
        root_add_tag(root_reward_tag(reward.blind_on_deck))
        root_create_random_retro_code()
    end
end

local function root_install_kernel(root_card)
    local state = root_state()
    if not state then
        return
    end

    state.enabled = true
    state.kernel_enabled = true
    state.level = (state.level or 0) + 1
    state.flags = state.flags or {}
    state.flags.kernel = true
    state.flags.free_shop = true
    state.flags.take_all_packs = true
    state.flags.full_deck_scoring = true
    state.flags.retro_replication = true
    state.flags.debuff_immunity = true

    root_capture_memory(root_card)
    root_install_slots()
    root_install_resources()
    root_break_blind()
    root_apply_existing_cards()
    root_duplicate_hand_to_deck()
    root_create_retro_suite()
    root_add_tag_suite()
    root_bloat_shop()
end

local function root_console_selected_card()
    local areas = {}
    if G.hand then areas[#areas + 1] = G.hand end
    if G.jokers then areas[#areas + 1] = G.jokers end
    if G.consumeables then areas[#areas + 1] = G.consumeables end
    if G.pack_cards then areas[#areas + 1] = G.pack_cards end
    if G.shop_jokers then areas[#areas + 1] = G.shop_jokers end
    if G.shop_booster then areas[#areas + 1] = G.shop_booster end
    if G.shop_vouchers then areas[#areas + 1] = G.shop_vouchers end

    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                if card and card.highlighted then
                    return card
                end
            end
        end
    end

    return nil
end

local function root_console_area_for_set(set)
    if set == "Joker" then
        root_expand_area(G.jokers, 1)
        return G.jokers
    end
    if set == "Booster" then
        root_expand_area(G.consumeables, 1)
        return G.consumeables
    end
    if set == "Voucher" then
        return G.shop_vouchers or G.consumeables
    end
    if set == "Tarot" or set == "Planet" or set == "Spectral" or set == "Code" or set == "geomancy" or set == "zodiac" or set == Vegasstuff.RETRO_CODE_SET then
        root_expand_area(G.consumeables, 1)
        return G.consumeables
    end

    return G.hand or G.deck
end

local function root_console_center(key)
    if not (key and G and G.P_CENTERS) then
        return nil
    end

    if G.P_CENTERS[key] then
        return G.P_CENTERS[key]
    end
    if G.P_CENTERS["j_" .. key] then
        return G.P_CENTERS["j_" .. key]
    end
    if G.P_CENTERS["c_" .. key] then
        return G.P_CENTERS["c_" .. key]
    end
    if G.P_CENTERS["c_vegasstuff_" .. key] then
        return G.P_CENTERS["c_vegasstuff_" .. key]
    end
    if G.P_CENTERS["p_" .. key] then
        return G.P_CENTERS["p_" .. key]
    end
    if G.P_CENTERS["v_" .. key] then
        return G.P_CENTERS["v_" .. key]
    end

    return nil
end

local function root_console_add(set, key, amount, area)
    if type(set) == "table" then
        local args = set
        set = args.set
        key = args.key
        amount = args.amount or args.copies
        area = args.area
    end

    local center = root_console_center(key)
    set = set or (center and center.set) or "Joker"
    amount = math.max(1, math.floor(tonumber(amount) or 1))
    area = area or root_console_area_for_set(set)
    root_expand_area(area, amount)

    local last_card = nil
    for _ = 1, amount do
        local created = SMODS.add_card({
            set = set,
            key = center and center.key or key,
            area = area
        })

        if created then
            last_card = created
        end
    end

    return last_card
end

local function root_console_retro(key, amount)
    if key and G.P_CENTERS and G.P_CENTERS["c_vegasstuff_" .. key] then
        key = "c_vegasstuff_" .. key
    end
    return root_console_add(Vegasstuff.RETRO_CODE_SET, key, amount, G.consumeables)
end

local function root_console_joker(key, amount)
    if key and G.P_CENTERS and G.P_CENTERS["j_" .. key] then
        key = "j_" .. key
    end
    return root_console_add("Joker", key, amount, G.jokers)
end

local function root_console_tag(key, amount)
    if not (G and G.P_TAGS and key) then
        return nil
    end

    if not G.P_TAGS[key] and G.P_TAGS["tag_" .. key] then
        key = "tag_" .. key
    end
    if not G.P_TAGS[key] then
        return nil
    end

    amount = math.max(1, math.floor(tonumber(amount) or 1))
    local last_tag = nil
    for _ = 1, amount do
        last_tag = Tag(key)
        add_tag(last_tag)
    end

    return last_tag
end

local function root_console_money(amount)
    amount = tonumber(amount) or 0
    ease_dollars(amount)
    return G.GAME and G.GAME.dollars
end

local function root_console_hands(amount)
    amount = tonumber(amount) or 0
    ease_hands_played(amount)
    return G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left
end

local function root_console_discards(amount)
    amount = tonumber(amount) or 0
    ease_discard(amount)
    return G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left
end

local function root_console_hand_size(amount)
    amount = tonumber(amount) or 0
    if G.hand and G.hand.config then
        G.hand.config.card_limit = math.max(1, G.hand.config.card_limit + amount)
    end
    return G.hand and G.hand.config and G.hand.config.card_limit
end

local function root_console_slots(jokers, consumeables)
    if G.jokers and G.jokers.config then
        G.jokers.config.card_limit = math.max(1, G.jokers.config.card_limit + (tonumber(jokers) or 0))
    end
    if G.consumeables and G.consumeables.config then
        G.consumeables.config.card_limit = math.max(1, G.consumeables.config.card_limit + (tonumber(consumeables) or 0))
    end
    return G.jokers and G.jokers.config and G.jokers.config.card_limit
end

local function root_console_blind(amount)
    if not (G and G.GAME and G.GAME.blind) then
        return nil
    end

    amount = math.max(1, Vegasstuff.to_number(amount, 1))
    G.GAME.blind.chips = amount
    G.GAME.blind.chip_text = number_format(amount)
    return G.GAME.blind.chips
end

local function root_console_score(amount)
    if not (G and G.GAME) then
        return nil
    end

    amount = Vegasstuff.to_number(amount, 0)
    G.GAME.chips = amount
    G.GAME.chips_text = number_format(amount)
    return G.GAME.chips
end

local function root_console_win()
    if G and G.GAME and G.GAME.blind then
        root_console_score(G.GAME.blind.chips or 1)
    end
    if end_round then
        end_round()
    end
    return true
end

local function root_console_copy(target, amount, area)
    target = target or root_console_selected_card()
    if not target then
        return nil
    end

    amount = math.max(1, math.floor(tonumber(amount) or 1))
    area = area or target.area or G.hand

    local last_copy = nil
    for _ = 1, amount do
        if root_is_playing_card(target) then
            G.playing_card = (G.playing_card or 0) + 1
        end

        local copy = copy_card(target, nil, nil, G.playing_card)
        if copy then
            if root_is_playing_card(copy) then
                copy:add_to_deck()
                G.playing_cards[#G.playing_cards + 1] = copy
            end
            root_expand_area(area, 1)
            area:emplace(copy)
            if copy.start_materialize then
                copy:start_materialize()
            end
            last_copy = copy
        end
    end

    return last_copy
end

local function root_console_destroy(target)
    target = target or root_console_selected_card()
    if target and target.start_dissolve then
        target:start_dissolve()
    end
    return target
end

local function root_console_edition(target, edition_key)
    if type(target) == "string" then
        edition_key = target
        target = root_console_selected_card()
    end
    target = target or root_console_selected_card()
    if not (target and edition_key) then
        return nil
    end

    local edition = {}
    edition[edition_key] = true
    target:set_edition(edition, true, true)
    return target
end

local function root_console_seal(target, seal_key)
    if type(target) == "string" then
        seal_key = target
        target = root_console_selected_card()
    end
    target = target or root_console_selected_card()
    if target and seal_key and target.set_seal then
        target:set_seal(seal_key, true, true)
    end
    return target
end

local function root_console_enhance(target, center_key)
    if type(target) == "string" then
        center_key = target
        target = root_console_selected_card()
    end
    target = target or root_console_selected_card()
    local center = root_console_center(center_key)
    if target and center and target.set_ability then
        target:set_ability(center)
    end
    return target
end

local function root_console_manipulate(target, mode, value)
    if type(target) == "string" then
        value = mode
        mode = target
        target = root_console_selected_card()
    end
    target = target or root_console_selected_card()
    if target and Cryptid and Cryptid.manipulate then
        Cryptid.manipulate(target, {
            type = mode,
            value = tonumber(value) or 1,
            bypass_checks = true,
            no_deck_effects = true
        })
    end
    return target
end

local function root_console_free_shop()
    local areas = {}
    if G.shop_jokers then areas[#areas + 1] = G.shop_jokers end
    if G.shop_booster then areas[#areas + 1] = G.shop_booster end
    if G.shop_vouchers then areas[#areas + 1] = G.shop_vouchers end

    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, card in ipairs(area.cards) do
                root_zero_cost(card)
            end
        end
    end

    return true
end

local function root_console_pool_keys(set)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[set]
    local keys = {}

    if pool then
        for _, center in ipairs(pool) do
            if center and center.key and not center.no_collection then
                keys[#keys + 1] = center.key
            end
        end
    end

    table.sort(keys)
    return keys
end

local function root_console_random_center_key(set, seed)
    local keys = root_console_pool_keys(set)
    if #keys == 0 then
        return nil
    end

    return pseudorandom_element(keys, pseudoseed(seed))
end

local function root_console_random_tag_key(seed)
    local keys = {}
    if G and G.P_TAGS then
        for key, _ in pairs(G.P_TAGS) do
            keys[#keys + 1] = key
        end
    end

    table.sort(keys)
    if #keys == 0 then
        return nil
    end

    return pseudorandom_element(keys, pseudoseed(seed))
end

local function root_console_random_joker()
    return root_console_joker(root_console_random_center_key("Joker", "vegasstuff_root_random_joker"), 1)
end

local function root_console_random_retro()
    return root_console_retro(root_random_retro_code_key(), 1)
end

local function root_console_random_tag()
    return root_console_tag(root_console_random_tag_key("vegasstuff_root_random_tag"), 1)
end

local function root_console_custom_buttons()
    local state = root_state()
    if not state then
        return {}
    end

    state.custom_buttons = state.custom_buttons or {}
    return state.custom_buttons
end

local function root_console_add_button(label, code)
    local buttons = root_console_custom_buttons()
    label = tostring(label or "CUSTOM")
    code = tostring(code or G.VEGASSTUFF_ROOT_CODE or "")

    if #buttons >= ROOT_CUSTOM_BUTTON_LIMIT then
        table.remove(buttons, 1)
    end

    buttons[#buttons + 1] = {
        label = label,
        code = code
    }

    G.VEGASSTUFF_ROOT_OUTPUT = "button added: " .. label
    return label
end

local function root_console_attach_script(target, code, label)
    if type(target) == "string" then
        label = code
        code = target
        target = root_console_selected_card()
    end

    target = target or root_console_selected_card()
    code = tostring(code or G.VEGASSTUFF_ROOT_CODE or "")
    if not (target and target.ability and code ~= "") then
        G.VEGASSTUFF_ROOT_OUTPUT = "highlight a card, then run script(\"code\")"
        return nil
    end

    target.ability.vegasstuff_root_script = code
    target.ability.vegasstuff_root_script_label = tostring(label or "ROOT SCRIPT")
    if target.juice_up then
        target:juice_up(0.3, 0.5)
    end

    G.VEGASSTUFF_ROOT_OUTPUT = "script attached: " .. target.ability.vegasstuff_root_script_label
    return target
end

local function root_console_forge(kind, code, label)
    kind = kind or "joker"
    local created = nil

    if kind == "retro" then
        created = root_console_retro("root", 1)
    elseif kind == "card" then
        created = root_console_add("Default", "c_base", 1, G.hand)
    else
        created = root_console_joker("j_joker", 1)
    end

    if created then
        root_console_attach_script(created, code or G.VEGASSTUFF_ROOT_CODE, label or "FORGED")
    end

    return created
end

local function root_console_print(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    G.VEGASSTUFF_ROOT_OUTPUT = table.concat(parts, "  ")
    if print then
        print(G.VEGASSTUFF_ROOT_OUTPUT)
    end
    return G.VEGASSTUFF_ROOT_OUTPUT
end

local function root_console_help()
    return "G, SMODS, money(n), joker(key,n), retro(key,n), tag(key,n), win(), selected(), copy(card,n), edition(key), x(card,n), script(code), forge(kind,code), button(label,code)"
end

local function root_console_environment()
    return {
        G = G,
        SMODS = SMODS,
        Vegasstuff = Vegasstuff,
        Cryptid = Cryptid,
        Talisman = Talisman,
        Card = Card,
        CardArea = CardArea,
        Blind = Blind,
        Back = Back,
        Game = Game,
        Event = Event,
        Tag = Tag,
        UIBox = UIBox,
        DynaText = DynaText,
        Sprite = Sprite,
        math = math,
        table = table,
        string = string,
        pairs = pairs,
        ipairs = ipairs,
        next = next,
        select = select,
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        assert = assert,
        error = error,
        pcall = pcall,
        unpack = table.unpack or unpack,
        print = root_console_print,
        help = root_console_help,
        selected = root_console_selected_card,
        add = root_console_add,
        card = root_console_add,
        joker = root_console_joker,
        retro = root_console_retro,
        tag = root_console_tag,
        random_joker = root_console_random_joker,
        random_retro = root_console_random_retro,
        random_tag = root_console_random_tag,
        money = root_console_money,
        dollars = root_console_money,
        hands = root_console_hands,
        discards = root_console_discards,
        hand_size = root_console_hand_size,
        slots = root_console_slots,
        blind = root_console_blind,
        score = root_console_score,
        win = root_console_win,
        copy = root_console_copy,
        clone = root_console_copy,
        destroy = root_console_destroy,
        edition = root_console_edition,
        seal = root_console_seal,
        enhance = root_console_enhance,
        x = function(target, value) return root_console_manipulate(target, "X", value) end,
        plus = function(target, value) return root_console_manipulate(target, "+", value) end,
        script = root_console_attach_script,
        forge = root_console_forge,
        button = root_console_add_button,
        free_shop = root_console_free_shop,
        create_card = create_card,
        create_card_for_shop = create_card_for_shop,
        copy_card = copy_card,
        draw_card = draw_card,
        add_tag = add_tag,
        ease_dollars = ease_dollars,
        ease_hands_played = ease_hands_played,
        ease_discard = ease_discard,
        end_round = end_round,
        number_format = number_format,
        localize = localize,
        HEX = HEX,
        darken = darken,
        lighten = lighten,
        copy_table = copy_table,
        pseudorandom = pseudorandom,
        pseudorandom_element = pseudorandom_element,
        pseudoseed = pseudoseed,
        to_big = to_big,
        to_number = to_number,
        card_eval_status_text = card_eval_status_text,
        play_sound = play_sound
    }
end

local function root_run_card_script(card, context)
    local script = card and card.ability and card.ability.vegasstuff_root_script
    if not (script and script ~= "") then
        return nil
    end
    if context and context.vegasstuff_root_script then
        return nil
    end

    local chunk, err = loadstring("return " .. script)
    if not chunk then
        chunk, err = loadstring(script)
    end
    if not chunk then
        G.VEGASSTUFF_ROOT_OUTPUT = tostring(err)
        return nil
    end

    local env = root_console_environment()
    env.self = card
    env.card = card
    env.context = context or {}
    env.other_card = context and context.other_card
    env.scoring_hand = context and context.scoring_hand
    env.full_hand = context and context.full_hand
    env.root_context = {
        vegasstuff_root_script = true
    }

    setfenv(chunk, env)
    local ok, result = pcall(chunk)
    if ok then
        if card_eval_status_text and card then
            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = card.ability.vegasstuff_root_script_label or "ROOT",
                colour = HEX("0eff00")
            })
        end
        return result
    end

    G.VEGASSTUFF_ROOT_OUTPUT = tostring(result)
    return nil
end

local function root_console_result_text(a, b, c, d)
    if a == nil and b == nil and c == nil and d == nil then
        return "ok"
    end

    local parts = {}
    if a ~= nil then parts[#parts + 1] = tostring(a) end
    if b ~= nil then parts[#parts + 1] = tostring(b) end
    if c ~= nil then parts[#parts + 1] = tostring(c) end
    if d ~= nil then parts[#parts + 1] = tostring(d) end
    return table.concat(parts, "  ")
end

local function root_console_run(code)
    if not code or code == "" then
        G.VEGASSTUFF_ROOT_OUTPUT = root_console_help()
        return
    end

    local chunk, err = loadstring("return " .. code)
    if not chunk then
        chunk, err = loadstring(code)
    end
    if not chunk then
        G.VEGASSTUFF_ROOT_OUTPUT = tostring(err)
        return
    end

    setfenv(chunk, root_console_environment())
    local ok, a, b, c, d = pcall(chunk)
    if ok then
        G.VEGASSTUFF_ROOT_OUTPUT = root_console_result_text(a, b, c, d)
    else
        G.VEGASSTUFF_ROOT_OUTPUT = tostring(a)
    end
end

local function root_console_text(text, scale, colour, shadow)
    return {
        n = G.UIT.T,
        config = {
            text = text,
            scale = scale or 0.35,
            colour = colour or G.C.UI.TEXT_LIGHT,
            shadow = shadow
        }
    }
end

local function root_console_dyna(text, scale, colour)
    return {
        n = G.UIT.O,
        config = {
            object = DynaText({
                string = { text },
                colours = { colour or G.C.UI.TEXT_LIGHT },
                bump = true,
                scale = scale or 0.45
            })
        }
    }
end

local function root_console_button(label, button, colour, minw)
    return UIBox_button({
        colour = colour or HEX("0eff00"),
        button = button,
        label = { label },
        minw = minw or 1.45,
        minh = 0.48,
        scale = 0.35,
        focus_args = { snap_to = true }
    })
end

local function root_console_button_row(nodes, padding)
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = padding or 0.025 },
        nodes = nodes
    }
end

local function root_console_wrap_output(text)
    text = tostring(text or "")
    if text == "" then
        return { "ready" }
    end

    local width = 54
    local max_lines = 3
    local lines = {}
    local index = 1

    while index <= #text and #lines < max_lines do
        local next_index = math.min(index + width - 1, #text)
        lines[#lines + 1] = string.sub(text, index, next_index)
        index = next_index + 1
    end

    if index <= #text and #lines > 0 then
        lines[#lines] = string.sub(lines[#lines], 1, width - 3) .. "..."
    end

    return lines
end

local function root_console_output_box(output, shell_colour)
    local output_nodes = {}
    local lines = root_console_wrap_output(output)

    for _, line in ipairs(lines) do
        output_nodes[#output_nodes + 1] = {
            n = G.UIT.R,
            config = { align = "cl", padding = 0 },
            nodes = {
                root_console_text("> " .. line, 0.25, shell_colour, false)
            }
        }
    end

    return {
        n = G.UIT.R,
        config = {
            align = "cl",
            colour = HEX("07130d"),
            r = 0.08,
            padding = 0.08,
            minw = 8.2,
            minh = 0.9,
            emboss = 0.04
        },
        nodes = output_nodes
    }
end

local function root_console_section(title, colour, rows)
    local section_nodes = {
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.02 },
            nodes = {
                root_console_text(title, 0.31, colour, true)
            }
        }
    }

    for _, row in ipairs(rows) do
        section_nodes[#section_nodes + 1] = root_console_button_row(row)
    end

    return {
        n = G.UIT.C,
        config = {
            align = "tm",
            colour = HEX("10201c"),
            r = 0.08,
            padding = 0.06,
            minw = 2.65,
            minh = 2.05,
            emboss = 0.04
        },
        nodes = section_nodes
    }
end

local function root_console_custom_button_nodes(custom_buttons, shell_colour)
    local rows = {}
    local current_row = {}

    for i = 1, #custom_buttons do
        current_row[#current_row + 1] = root_console_button(custom_buttons[i].label, "vegasstuff_root_custom_" .. i, shell_colour, 1.25)
        if #current_row == 3 then
            rows[#rows + 1] = current_row
            current_row = {}
        end
    end

    if #current_row > 0 then
        rows[#rows + 1] = current_row
    end

    local nodes = {
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.02 },
            nodes = {
                root_console_text("PLAYER MACROS", 0.3, shell_colour, true)
            }
        }
    }

    for _, row in ipairs(rows) do
        nodes[#nodes + 1] = root_console_button_row(row)
    end

    return {
        n = G.UIT.R,
        config = {
            align = "cm",
            colour = HEX("10201c"),
            r = 0.08,
            padding = 0.06,
            emboss = 0.04,
            minw = 8.2
        },
        nodes = nodes
    }
end

local function root_console_box()
    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            G.REFRESH_ALERTS = true
            return true
        end
    }))

    local shell_colour = HEX("0eff00")
    local shell_dark = HEX("04200c")
    local danger_colour = HEX("ff9352")
    local output = G.VEGASSTUFF_ROOT_OUTPUT or root_console_help()
    local contents = {
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.02 },
            nodes = {
                root_console_dyna("://ROOT CONTROL", 0.55, shell_colour)
            }
        },
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.01 },
            nodes = {
                root_console_text("game-facing developer panel", 0.25, G.C.UI.TEXT_LIGHT, false)
            }
        },
        root_console_output_box(output, shell_colour),
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.05 },
            nodes = {
                create_text_input({
                    colour = shell_colour,
                    hooked_colour = darken(copy_table(shell_colour), 0.3),
                    w = 5.15,
                    h = 0.85,
                    max_length = 2500,
                    extended_corpus = true,
                    prompt_text = "money(999)",
                    ref_table = G,
                    ref_value = "VEGASSTUFF_ROOT_CODE",
                    keyboard_offset = 1
                }),
                root_console_button("RUN", "vegasstuff_root_execute", shell_colour, 1.25),
                root_console_button("CLOSE", "vegasstuff_root_close", G.C.RED, 1.45)
            }
        },
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04 },
            nodes = {
                root_console_section("POWER", shell_colour, {
                    {
                        root_console_button("$999", "vegasstuff_root_quick_money", shell_colour),
                        root_console_button("WIN", "vegasstuff_root_quick_win", shell_colour)
                    },
                    {
                        root_console_button("HANDS", "vegasstuff_root_quick_root_all", shell_colour, 1.55),
                        root_console_button("SHOP", "vegasstuff_root_quick_shop", shell_colour)
                    }
                }),
                root_console_section("SPAWN", danger_colour, {
                    {
                        root_console_button("JOKER", "vegasstuff_root_quick_joker", danger_colour),
                        root_console_button("RETRO", "vegasstuff_root_quick_retro", danger_colour)
                    },
                    {
                        root_console_button("TAG", "vegasstuff_root_quick_tag", danger_colour),
                        root_console_button("COPY", "vegasstuff_root_quick_copy", danger_colour)
                    }
                }),
                root_console_section("CUSTOM", shell_colour, {
                    {
                        root_console_button("NEG", "vegasstuff_root_quick_negative", shell_colour),
                        root_console_button("POLY", "vegasstuff_root_quick_polychrome", shell_colour)
                    },
                    {
                        root_console_button("X10", "vegasstuff_root_quick_x10", shell_colour),
                        root_console_button("SCRIPT", "vegasstuff_root_quick_script", shell_colour, 1.45)
                    },
                    {
                        root_console_button("FORGE", "vegasstuff_root_quick_forge", danger_colour),
                        root_console_button("MACRO", "vegasstuff_root_quick_button", danger_colour, 1.45)
                    },
                    {
                        root_console_button("HELP", "vegasstuff_root_quick_help", danger_colour),
                        root_console_button("CLEAR", "vegasstuff_root_quick_clear", danger_colour)
                    }
                })
            }
        }
    }

    local custom_buttons = root_console_custom_buttons()
    if #custom_buttons > 0 then
        contents[#contents + 1] = root_console_custom_button_nodes(custom_buttons, shell_colour)
    end

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.UI.TRANSPARENT_DARK,
            r = 0.1,
            padding = 0.05,
            emboss = 0.05
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    colour = shell_dark,
                    outline = 1.5,
                    outline_colour = shell_colour,
                    r = 0.12,
                    padding = 0.16,
                    minw = 8.6,
                    emboss = 0.06
                },
                nodes = contents
            }
        }
    }
end

local function root_close_console()
    if G.VEGASSTUFF_ROOT_CONSOLE then
        G.VEGASSTUFF_ROOT_CONSOLE:remove()
        G.VEGASSTUFF_ROOT_CONSOLE = nil
    end
    if G.GAME then
        G.GAME.USING_CODE = false
    end
end

local function root_open_console()
    local state = root_state()
    if state then
        state.enabled = false
        state.kernel_enabled = false
        state.last_blind_reward = nil
    end

    G.VEGASSTUFF_ROOT_CODE = G.VEGASSTUFF_ROOT_CODE or ""
    G.VEGASSTUFF_ROOT_OUTPUT = G.VEGASSTUFF_ROOT_OUTPUT or root_console_help()
    root_close_console()

    if G.GAME then
        G.GAME.USING_CODE = true
    end

    G.VEGASSTUFF_ROOT_CONSOLE = UIBox({
        definition = root_console_box(),
        config = {
            align = "cm",
            offset = { x = 0, y = 0 },
            major = G.ROOM_ATTACH,
            bond = "Weak",
            instance_type = "POPUP"
        }
    })
end

local function root_refresh_console()
    if G.VEGASSTUFF_ROOT_CONSOLE then
        root_open_console()
    end
end

G.FUNCS.vegasstuff_root_execute = function()
    root_console_run(G.VEGASSTUFF_ROOT_CODE)
    root_refresh_console()
end

G.FUNCS.vegasstuff_root_close = function()
    root_close_console()
end

local function root_quick_action(label, callback)
    local ok, result = pcall(callback)
    if ok then
        G.VEGASSTUFF_ROOT_OUTPUT = label .. ": " .. root_console_result_text(result)
    else
        G.VEGASSTUFF_ROOT_OUTPUT = tostring(result)
    end
    root_refresh_console()
end

G.FUNCS.vegasstuff_root_quick_money = function()
    root_quick_action("$999", function()
        return root_console_money(999)
    end)
end

G.FUNCS.vegasstuff_root_quick_win = function()
    root_quick_action("win", root_console_win)
end

G.FUNCS.vegasstuff_root_quick_root_all = function()
    root_quick_action("hands", function()
        root_console_hands(99)
        return root_console_discards(99)
    end)
end

G.FUNCS.vegasstuff_root_quick_shop = function()
    root_quick_action("shop", root_console_free_shop)
end

G.FUNCS.vegasstuff_root_quick_joker = function()
    root_quick_action("joker", root_console_random_joker)
end

G.FUNCS.vegasstuff_root_quick_retro = function()
    root_quick_action("retro", root_console_random_retro)
end

G.FUNCS.vegasstuff_root_quick_tag = function()
    root_quick_action("tag", root_console_random_tag)
end

G.FUNCS.vegasstuff_root_quick_copy = function()
    root_quick_action("copy", function()
        return root_console_copy(root_console_selected_card(), 5)
    end)
end

G.FUNCS.vegasstuff_root_quick_negative = function()
    root_quick_action("negative", function()
        return root_console_edition("negative")
    end)
end

G.FUNCS.vegasstuff_root_quick_polychrome = function()
    root_quick_action("polychrome", function()
        return root_console_edition("polychrome")
    end)
end

G.FUNCS.vegasstuff_root_quick_x10 = function()
    root_quick_action("x10", function()
        return root_console_manipulate("X", 10)
    end)
end

G.FUNCS.vegasstuff_root_quick_script = function()
    root_quick_action("script", function()
        return root_console_attach_script(G.VEGASSTUFF_ROOT_CODE)
    end)
end

G.FUNCS.vegasstuff_root_quick_forge = function()
    root_quick_action("forge", function()
        return root_console_forge("joker", G.VEGASSTUFF_ROOT_CODE, "FORGED")
    end)
end

G.FUNCS.vegasstuff_root_quick_button = function()
    root_quick_action("button", function()
        return root_console_add_button("CUSTOM", G.VEGASSTUFF_ROOT_CODE)
    end)
end

G.FUNCS.vegasstuff_root_quick_help = function()
    G.VEGASSTUFF_ROOT_OUTPUT = root_console_help()
    root_refresh_console()
end

G.FUNCS.vegasstuff_root_quick_clear = function()
    G.VEGASSTUFF_ROOT_CODE = ""
    G.VEGASSTUFF_ROOT_OUTPUT = "cleared"
    root_refresh_console()
end

for i = 1, ROOT_CUSTOM_BUTTON_LIMIT do
    local slot = i
    G.FUNCS["vegasstuff_root_custom_" .. i] = function()
        local button = root_console_custom_buttons()[slot]
        if button then
            root_console_run(button.code)
        else
            G.VEGASSTUFF_ROOT_OUTPUT = "missing custom button"
        end
        root_refresh_console()
    end
end

if not _G.vegasstuff_root_hooks_installed then
    _G.vegasstuff_root_hooks_installed = true
    local unpack_fn = table.unpack or unpack

    local always_scores_ref = SMODS.always_scores
    function SMODS.always_scores(card, ...)
        if root_enabled() and card and card.ability and card.ability.vegasstuff_rooted then
            return true
        end
        return always_scores_ref(card, ...)
    end

    local debuff_card_ref = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        local results = { debuff_card_ref(self, card, from_blind) }
        if root_enabled() and card and card.ability then
            card.ability.vegasstuff_rooted = true
            if card.set_debuff then
                card:set_debuff(false)
            else
                card.debuff = false
            end
        end
        return unpack_fn(results)
    end

    local set_cost_ref = Card.set_cost
    function Card:set_cost(...)
        local results = { set_cost_ref(self, ...) }
        if root_enabled() and root_is_shop_card(self) then
            root_zero_cost(self)
        end
        return unpack_fn(results)
    end

    local emplace_ref = CardArea.emplace
    function CardArea:emplace(card, ...)
        local results = { emplace_ref(self, card, ...) }
        if root_enabled() then
            root_apply_card(card)
        end
        return unpack_fn(results)
    end

    local card_open_ref = Card.open
    function Card:open(...)
        local results = { card_open_ref(self, ...) }
        root_prepare_pack(self)
        return unpack_fn(results)
    end

    local use_consumeable_ref = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local is_retro = self and self.config and self.config.center and self.config.center.set == Vegasstuff.RETRO_CODE_SET
        local is_root = self and self.config and self.config.center_key == "c_vegasstuff_root"
        local results = { use_consumeable_ref(self, area, copier) }

        if root_enabled() and is_retro then
            local state = root_state()
            if state then
                state.retro_uses = (state.retro_uses or 0) + 1
            end
            if not is_root then
                root_create_random_retro_code()
            end
        end

        root_run_card_script(self, {
            using_consumeable = true,
            area = area,
            copier = copier
        })

        return unpack_fn(results)
    end

    if Card.calculate_joker then
        local calculate_joker_ref = Card.calculate_joker
        function Card:calculate_joker(context)
            local script_result = root_run_card_script(self, context)
            local results = { calculate_joker_ref(self, context) }
            if script_result ~= nil then
                return script_result
            end
            return unpack_fn(results)
        end
    end

    local evaluate_play_ref = G.FUNCS.evaluate_play
    function G.FUNCS.evaluate_play(e)
        local state = root_state()
        if state then
            state.scored_this_play = nil
        end
        return evaluate_play_ref(e)
    end

    _G.vegasstuff_root_score_card_ref = SMODS.score_card
    function SMODS.score_card(card, context)
        _G.vegasstuff_root_score_card_ref(card, context)
        root_run_card_script(card, context)
        if context and context.cardarea == G.play and not context.vegasstuff_root_phantom then
            root_score_phantoms(context)
        end
    end

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local state = root_state()
        if state and state.enabled and G and G.GAME and G.GAME.blind then
            state.last_blind_reward = {
                dollars = G.GAME.blind.dollars or 0,
                blind_on_deck = G.GAME.blind_on_deck
            }
        end

        local results = { evaluate_round_ref(...) }

        if state and state.enabled then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    root_cashout_kernel(state)
                    return true
                end
            }))
        end

        return unpack_fn(results)
    end

    local update_shop_ref = Game.update_shop
    function Game:update_shop(dt)
        local results = { update_shop_ref(self, dt) }
        root_bloat_shop()
        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "root",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return true
    end,
    use = function(self, card)
        root_open_console()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 1)
