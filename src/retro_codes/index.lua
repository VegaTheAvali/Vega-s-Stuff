local INDEX_EXTRA_CARDS = 2

local function index_arm_next_pack()
    G.GAME.vegasstuff_index_next_pack = {
        extra_cards = INDEX_EXTRA_CARDS
    }
end

local function index_make_pack_take_all(booster)
    local index_data = G and G.GAME and G.GAME.vegasstuff_index_next_pack
    if not (index_data and booster and booster.ability and booster.ability.set == "Booster") then
        return
    end

    G.GAME.vegasstuff_index_next_pack = nil
    G.GAME.vegasstuff_index_active = true

    local extra_cards = index_data.extra_cards or INDEX_EXTRA_CARDS
    booster.ability.extra = math.min(500, (tonumber(booster.ability.extra) or 1) + extra_cards)
    booster.ability.choose = booster.ability.extra
    G.GAME.pack_size = booster.ability.extra
    G.GAME.pack_choices = booster.ability.extra
end

local function index_should_upgrade_pack_card(card)
    return G
        and G.GAME
        and G.GAME.vegasstuff_index_active
        and card
        and card.area == G.pack_cards
end

local function index_clear_pack_state()
    if G and G.GAME then
        G.GAME.vegasstuff_index_active = nil
    end
end

if not _G.vegasstuff_index_hooks_installed then
    _G.vegasstuff_index_hooks_installed = true

    local card_open_ref = Card.open
    function Card:open(...)
        local results = { card_open_ref(self, ...) }
        index_make_pack_take_all(self)
        return (table.unpack or unpack)(results)
    end

    local use_card_ref = G.FUNCS.use_card
    function G.FUNCS.use_card(e, mute, nosave)
        local card = e and e.config and e.config.ref_table
        if index_should_upgrade_pack_card(card) then
            card:set_edition({ negative = true }, true, true)
        end

        return use_card_ref(e, mute, nosave)
    end

    local end_consumeable_ref = G.FUNCS.end_consumeable
    function G.FUNCS.end_consumeable(e, delayfac)
        index_clear_pack_state()
        return end_consumeable_ref(e, delayfac)
    end
end

Vegasstuff.retro_code_consumable({
    key = "index",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            extra_cards = INDEX_EXTRA_CARDS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.extra_cards } }
    end,
    can_use = function()
        return true
    end,
    use = function()
        index_arm_next_pack()
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 16)
