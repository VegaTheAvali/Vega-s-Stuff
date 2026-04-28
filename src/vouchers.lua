do
local function set_consumable_shop_rate(rate_key, rate)
    G.E_MANAGER:add_event(Event({
        func = function()
            G.GAME[rate_key] = rate
            return true
        end,
    }))
end

local function consumable_rate_voucher(args)
    SMODS.Voucher {
        key = args.key,
        order = args.order,
        atlas = "Vouchers",
        pos = args.pos,
        cost = 10,
        unlocked = true,
        discovered = true,
        available = true,
        requires = args.requires,
        config = {
            extra = {
                rate_key = args.rate_key,
                rate = args.rate,
                display = args.display,
            },
        },
        loc_vars = function(self, info_queue, card)
            local extra = card and card.ability and card.ability.extra or self.config.extra
            return { vars = { extra.display } }
        end,
        redeem = function(self, card)
            local extra = card and card.ability and card.ability.extra or self.config.extra
            set_consumable_shop_rate(extra.rate_key, 4 * extra.rate)
        end,
    }
end

consumable_rate_voucher {
    key = "zodiac_merchant",
    order = 1,
    pos = { x = 0, y = 0 },
    rate_key = "zodiac_rate",
    rate = 9.6 / 4,
    display = 2,
}

consumable_rate_voucher {
    key = "geomancy_merchant",
    order = 2,
    pos = { x = 1, y = 0 },
    rate_key = "geomancy_rate",
    rate = 9.6 / 4,
    display = 2,
}

consumable_rate_voucher {
    key = "zodiac_tycoon",
    order = 3,
    pos = { x = 0, y = 1 },
    requires = { "v_vegasstuff_zodiac_merchant" },
    rate_key = "zodiac_rate",
    rate = 32 / 4,
    display = 4,
}

consumable_rate_voucher {
    key = "geomancy_tycoon",
    order = 4,
    pos = { x = 1, y = 1 },
    requires = { "v_vegasstuff_geomancy_merchant" },
    rate_key = "geomancy_rate",
    rate = 32 / 4,
    display = 4,
}
end
