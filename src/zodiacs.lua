local ZODIACS = {
    { key = 'aries', enhancement_key = 'm_vegasstuff_wartorn', pos = { x = 0, y = 0 }, soul_pos = { x = 1, y = 0 } },
    { key = 'gemini', enhancement_key = 'm_vegasstuff_anaphase', pos = { x = 2, y = 0 }, soul_pos = { x = 3, y = 0 } },
    { key = 'leo', enhancement_key = 'm_vegasstuff_midas', pos = { x = 4, y = 0 }, soul_pos = { x = 5, y = 0 } },
    { key = 'libra', enhancement_key = 'm_vegasstuff_duality', pos = { x = 6, y = 0 }, soul_pos = { x = 7, y = 0 } },
    { key = 'sagittarius', enhancement_key = 'm_vegasstuff_toxin', pos = { x = 8, y = 0 }, soul_pos = { x = 9, y = 0 } },
    { key = 'aquarius', enhancement_key = 'm_vegasstuff_soggy', pos = { x = 0, y = 1 }, soul_pos = { x = 1, y = 1 } },
    { key = 'cancer', enhancement_key = 'm_vegasstuff_creased', pos = { x = 2, y = 1 }, soul_pos = { x = 3, y = 1 } },
    { key = 'virgo', enhancement_key = 'm_vegasstuff_stitched', pos = { x = 4, y = 1 }, soul_pos = { x = 5, y = 1 } },
    { key = 'scorpio', enhancement_key = 'm_vegasstuff_tapered', pos = { x = 6, y = 1 }, soul_pos = { x = 7, y = 1 } },
    { key = 'capricorn', enhancement_key = 'm_vegasstuff_scoped', pos = { x = 8, y = 1 }, soul_pos = { x = 9, y = 1 } },
    { key = 'taurus', enhancement_key = 'm_vegasstuff_rusted', pos = { x = 0, y = 2 }, soul_pos = { x = 1, y = 2 } },
    { key = 'pisces', enhancement_key = 'm_vegasstuff_dreamy', pos = { x = 2, y = 2 }, soul_pos = { x = 3, y = 2 } },
}

local function highlighted_count()
    if not G or not G.hand or not G.hand.highlighted then
        return 0
    end
    return #G.hand.highlighted
end

local function has_one_highlighted_card()
    return to_big(highlighted_count()) == to_big(1)
end

local function add_after_event(delay, func)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = delay,
        func = func
    }))
end

local function juice_used_card(used_card)
    add_after_event(0.4, function()
        play_sound('tarot1')
        used_card:juice_up(0.3, 0.5)
        return true
    end)
end

local function flip_highlighted_cards(sound_key, percent_start, percent_end, volume)
    local selected_cards = G.hand.highlighted
    for i = 1, #selected_cards do
        local selected_card = selected_cards[i]
        local percent = percent_start + (i - 0.999) / (#selected_cards - 0.998) * (percent_end - percent_start)
        add_after_event(0.15, function()
            selected_card:flip()
            play_sound(sound_key, percent, volume)
            selected_card:juice_up(0.3, 0.3)
            return true
        end)
    end
end

local function apply_enhancement_to_highlighted(enhancement_key)
    local selected_cards = G.hand.highlighted
    for i = 1, #selected_cards do
        local selected_card = selected_cards[i]
        add_after_event(0.1, function()
            selected_card:set_ability(G.P_CENTERS[enhancement_key])
            return true
        end)
    end
end

local function finish_zodiac_use()
    add_after_event(0.2, function()
        G.hand:unhighlight_all()
        return true
    end)
    delay(0.5)
end

local function use_zodiac_card(enhancement_key, card, copier)
    local used_card = copier or card

    if not has_one_highlighted_card() then
        return
    end

    juice_used_card(used_card)
    flip_highlighted_cards('card1', 1.15, 0.85)
    delay(0.2)
    apply_enhancement_to_highlighted(enhancement_key)
    flip_highlighted_cards('tarot2', 0.85, 1.15, 0.6)
    finish_zodiac_use()
end

for i = 1, #ZODIACS do
    local zodiac = ZODIACS[i]

    SMODS.Consumable {
        key = zodiac.key,
        set = 'zodiac',
        pos = zodiac.pos,
        soul_pos = zodiac.soul_pos,
        cost = 3,
        unlocked = true,
        discovered = true,
        hidden = false,
        can_repeat_soul = false,
        atlas = 'ZodiacCards',
        use = function(self, card, area, copier)
            use_zodiac_card(zodiac.enhancement_key, card, copier)
        end,
        can_use = function(self, card)
            return has_one_highlighted_card()
        end
    }
end
