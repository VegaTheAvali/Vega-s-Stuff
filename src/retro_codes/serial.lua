local SERIAL_TAGS = 2

local function golden_voucher_tag_available()
    return G
        and G.P_TAGS
        and G.P_TAGS.tag_cry_better_voucher
        and G.GAME
        and G.GAME.round_resets
        and (G.GAME.round_resets.ante or 1) >= 4
end

local function add_serial_tag(tag_key)
    if G and G.P_TAGS and G.P_TAGS[tag_key] then
        add_tag(Tag(tag_key))
    end
end

Vegasstuff.retro_code_consumable({
    key = "serial",
    
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            tags = SERIAL_TAGS
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.tags } }
    end,
    can_use = function()
        return true
    end,
    use = function(self)
        local made_golden = false

        for _ = 1, self.config.extra.tags do
            if not made_golden and golden_voucher_tag_available() then
                add_serial_tag("tag_cry_better_voucher")
                made_golden = true
            else
                add_serial_tag("tag_voucher")
            end
        end
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 3)
