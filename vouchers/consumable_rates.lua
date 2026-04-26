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
        loc_txt = {
            name = args.name,
            text = {
                "{C:" .. args.colour .. "}" .. args.card_type .. "{} cards",
                "appear {C:attention}#1#X{} more",
                "frequently in the shop",
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
    name = "Zodiac Merchant",
    card_type = "Zodiac",
    colour = "purple",
    pos = { x = 0, y = 0 },
    rate_key = "zodiac_rate",
    rate = 9.6 / 4,
    display = 2,
}

consumable_rate_voucher {
    key = "geomancy_merchant",
    order = 2,
    name = "Geomancy Merchant",
    card_type = "Geomancy",
    colour = "attention",
    pos = { x = 1, y = 0 },
    rate_key = "geomancy_rate",
    rate = 9.6 / 4,
    display = 2,
}

consumable_rate_voucher {
    key = "zodiac_tycoon",
    order = 3,
    name = "Zodiac Tycoon",
    card_type = "Zodiac",
    colour = "purple",
    pos = { x = 0, y = 1 },
    requires = { "v_vegasstuff_zodiac_merchant" },
    rate_key = "zodiac_rate",
    rate = 32 / 4,
    display = 4,
}

consumable_rate_voucher {
    key = "geomancy_tycoon",
    order = 4,
    name = "Geomancy Tycoon",
    card_type = "Geomancy",
    colour = "attention",
    pos = { x = 1, y = 1 },
    requires = { "v_vegasstuff_geomancy_merchant" },
    rate_key = "geomancy_rate",
    rate = 32 / 4,
    display = 4,
}
