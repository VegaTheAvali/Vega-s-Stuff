local CACHE_HISTORY_LIMIT = 8
local CACHE_COPY_COUNT = 2
local CACHE_MULTIUSE = 2

local function cache_history()
    if not (G and G.GAME) then
        return {}
    end

    G.GAME.vegasstuff_consumable_history = G.GAME.vegasstuff_consumable_history or {}
    return G.GAME.vegasstuff_consumable_history
end

local function cache_record_consumable(card)
    if not (G and G.GAME and card and card.config and card.config.center_key) then
        return
    end

    local center = card.config.center
    if not (center and center.set) then
        return
    end

    local history = cache_history()
    history[#history + 1] = {
        key = card.config.center_key,
        set = center.set
    }

    while #history > CACHE_HISTORY_LIMIT do
        table.remove(history, 1)
    end
end

local function cache_last_entries()
    local history = cache_history()
    local entries = {}

    for i = #history, 1, -1 do
        local entry = history[i]
        if entry and entry.key ~= "c_vegasstuff_cache" then
            entries[#entries + 1] = entry
        end

        if #entries >= CACHE_COPY_COUNT then
            break
        end
    end

    return entries
end

local function cache_consumable_room()
    if not (G and G.consumeables and G.consumeables.cards and G.consumeables.config) then
        return 0
    end

    return G.consumeables.config.card_limit - #G.consumeables.cards - (G.GAME.consumeable_buffer or 0)
end

local function cache_is_retro(entry)
    local center = entry and entry.key and G.P_CENTERS and G.P_CENTERS[entry.key]
    return center and center.set == Vegasstuff.RETRO_CODE_SET
end

local function cache_create_entry(entry)
    local center = entry and entry.key and G.P_CENTERS and G.P_CENTERS[entry.key]
    if not center then
        return nil
    end

    local created = SMODS.add_card({
        set = center.set,
        key = center.key,
        area = G.consumeables
    })
    created.ability.cry_multiuse = CACHE_MULTIUSE

    if center.set == Vegasstuff.RETRO_CODE_SET then
        created:set_edition({ negative = true }, true, true)
    end

    created:juice_up(0.3, 0.5)
    return created
end

local function cache_random_retro_code_key()
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    local choices = {}

    if pool then
        for _, center in ipairs(pool) do
            if center.key ~= "c_vegasstuff_cache" and not center.no_collection then
                choices[#choices + 1] = center.key
            end
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed("vegasstuff_cache_retro"))
end

local function cache_create_random_retro_code()
    local key = cache_random_retro_code_key()
    if not key then
        return
    end

    local created = SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
    created.ability.cry_multiuse = CACHE_MULTIUSE
    created:set_edition({ negative = true }, true, true)
    created:juice_up(0.3, 0.5)
end

if not _G.vegasstuff_cache_hooks_installed then
    _G.vegasstuff_cache_hooks_installed = true

    local use_consumeable_ref = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local results = { use_consumeable_ref(self, area, copier) }
        cache_record_consumable(self)
        return (table.unpack or unpack)(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "cache",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            copies = CACHE_COPY_COUNT,
            multiuse = CACHE_MULTIUSE
        }
    },
    loc_vars = function(self)
        return {
            vars = {
                self.config.extra.copies,
                self.config.extra.multiuse
            }
        }
    end,
    can_use = function()
        return #cache_last_entries() > 0 and cache_consumable_room() > 0
    end,
    use = function()
        local entries = cache_last_entries()
        local retro_copies = 0
        local room = cache_consumable_room()

        for i = 1, math.min(#entries, CACHE_COPY_COUNT, room) do
            if cache_is_retro(entries[i]) then
                retro_copies = retro_copies + 1
            end
            cache_create_entry(entries[i])
        end

        if retro_copies >= CACHE_COPY_COUNT and cache_consumable_room() > 0 then
            cache_create_random_retro_code()
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 19)
