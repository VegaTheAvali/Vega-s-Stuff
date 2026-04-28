local function buserr_target(scoring_hand)
    if not scoring_hand or #scoring_hand == 0 then
        return nil
    end

    if #scoring_hand % 2 == 1 then
        return scoring_hand[(#scoring_hand + 1) / 2]
    end

    local seed = "vegasstuff_buserr_" .. (G.GAME.round_resets.ante or 0) .. "_" .. (G.GAME.current_round.hands_played or 0)
    return pseudorandom_element(scoring_hand, pseudoseed(seed))
end

if not _G.vegasstuff_buserr_hooks_installed then
    _G.vegasstuff_buserr_hooks_installed = true

    local calculate_repetitions_ref = SMODS.calculate_repetitions
    function SMODS.calculate_repetitions(card, context, reps)
        calculate_repetitions_ref(card, context, reps)

        if not (G and G.GAME and G.GAME.vegasstuff_buserr_next_hand) then
            return
        end

        if not (context.repetition and context.cardarea == G.play and context.scoring_hand and context.other_card) then
            return
        end

        G.GAME.vegasstuff_buserr_target = G.GAME.vegasstuff_buserr_target or buserr_target(context.scoring_hand)
        if context.other_card ~= G.GAME.vegasstuff_buserr_target then
            return
        end

        SMODS.insert_repetitions(reps, {
            repetitions = 1,
            card = context.other_card,
            colour = G.C.SECONDARY_SET.Code,
            message = localize("k_again_ex")
        }, context.other_card)

        G.GAME.vegasstuff_buserr_next_hand = nil
        G.GAME.vegasstuff_buserr_target = nil
    end
end

Vegasstuff.retro_code_consumable({
    key = "buserr",
    loc_txt = {
        name = "://BUSERR",
        text = {
            "The next played {C:attention}hand{}",
            "retriggers its {C:attention}middle{} scoring card",
            "{C:attention}1{} additional time",
            "{C:inactive}(Random if there is no middle card){}"
        }
    },
    unlocked = true,
    discovered = true,
    cost = 4,
    can_use = function()
        return G and G.GAME and Cryptid.safe_get(G.GAME, "blind", "in_blind") and not G.GAME.USING_RUN
    end,
    use = function()
        G.GAME.vegasstuff_buserr_next_hand = true
        G.GAME.vegasstuff_buserr_target = nil
    end,
    force_use = function(self, card, area)
        self:use(card, area)
    end
}, 7)
