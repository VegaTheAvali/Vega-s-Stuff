local TROJAN_BASE_REWARD = 1
local TROJAN_BOSS_REWARD = 2
local unpack_fn = table.unpack or unpack

local function random_retro_code_key(seed)
    local pool = G and G.P_CENTER_POOLS and G.P_CENTER_POOLS[Vegasstuff.RETRO_CODE_SET]
    if not pool then
        return nil
    end

    local choices = {}
    for _, center in ipairs(pool) do
        if center.key ~= "c_vegasstuff_trojan" and not center.no_collection then
            choices[#choices + 1] = center.key
        end
    end

    if #choices == 0 then
        return nil
    end

    return pseudorandom_element(choices, pseudoseed(seed))
end

local function create_trojan_reward(seed)
    local key = random_retro_code_key(seed)
    if not key then
        return
    end

    SMODS.add_card({
        set = Vegasstuff.RETRO_CODE_SET,
        key = key,
        area = G.consumeables
    })
end

if not _G.vegasstuff_trojan_hooks_installed then
    _G.vegasstuff_trojan_hooks_installed = true

    local evaluate_round_ref = G.FUNCS.evaluate_round
    function G.FUNCS.evaluate_round(...)
        local pending = G and G.GAME and G.GAME.vegasstuff_trojan_payloads or 0
        local blind_on_deck = G and G.GAME and G.GAME.blind_on_deck
        local results = { evaluate_round_ref(...) }

        if pending > 0 then
            local reward_count = pending * (blind_on_deck == "Boss" and TROJAN_BOSS_REWARD or TROJAN_BASE_REWARD)
            G.GAME.vegasstuff_trojan_payloads = nil

            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.5,
                func = function()
                    for i = 1, reward_count do
                        create_trojan_reward("vegasstuff_trojan_" .. i .. "_" .. G.GAME.round_resets.ante)
                    end
                    return true
                end
            }))
        end

        return unpack_fn(results)
    end
end

Vegasstuff.retro_code_consumable({
    key = "trojan",
    loc_txt = {
        name = "://TROJAN",
        text = {
            "Plant a {C:green}payload{} on the next {C:attention}Blind{}",
            "When defeated, create {C:attention}#1#{}",
            "random {C:green}Retro Code{}",
            "{C:attention}Boss Blinds{} create {C:attention}#2#{} instead"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    config = {
        extra = {
            base_reward = TROJAN_BASE_REWARD,
            boss_reward = TROJAN_BOSS_REWARD
        }
    },
    loc_vars = function(self)
        return { vars = { self.config.extra.base_reward, self.config.extra.boss_reward } }
    end,
    can_use = function()
        return true
    end,
    use = function(self)
        G.GAME.vegasstuff_trojan_payloads = (G.GAME.vegasstuff_trojan_payloads or 0) + 1
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 4)
