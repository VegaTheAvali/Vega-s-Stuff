Vegasstuff = Vegasstuff or {}
Vegasstuff.compat = Vegasstuff.compat or {}

local function vegasstuff_seed_missing_poker_hand(handname)
    if not (G and G.GAME and G.GAME.hands and SMODS and SMODS.PokerHands) then
        return
    end

    if G.GAME.hands[handname] or not SMODS.PokerHands[handname] then
        return
    end

    local hand = SMODS.PokerHands[handname]
    G.GAME.hands[handname] = {
        visible = hand.visible == true,
        order = hand.order or 999,
        mult = hand.mult or 1,
        chips = hand.chips or 0,
        s_mult = hand.s_mult or hand.mult or 1,
        s_chips = hand.s_chips or hand.chips or 0,
        level = hand.level or 1,
        l_mult = hand.l_mult or 1,
        l_chips = hand.l_chips or 0,
        played = 0,
        played_this_round = 0,
        example = hand.example
    }
end

function Vegasstuff.compat.seed_missing_poker_hands()
    if not (G and G.GAME and G.GAME.hands and SMODS and SMODS.PokerHands and G.handlist) then
        return
    end

    for _, handname in ipairs(G.handlist) do
        vegasstuff_seed_missing_poker_hand(handname)
    end
end

if not Vegasstuff.compat.seed_missing_poker_hands_start_run_ref then
    Vegasstuff.compat.seed_missing_poker_hands_start_run_ref = Game.start_run

    function Game:start_run(args)
        Vegasstuff.compat.seed_missing_poker_hands_start_run_ref(self, args)
        Vegasstuff.compat.seed_missing_poker_hands()
    end
end

if SMODS and SMODS.is_poker_hand_visible and not Vegasstuff.compat.safe_poker_hand_visible_ref then
    Vegasstuff.compat.safe_poker_hand_visible_ref = SMODS.is_poker_hand_visible

    function SMODS.is_poker_hand_visible(handname)
        vegasstuff_seed_missing_poker_hand(handname)

        if not (G and G.GAME and G.GAME.hands and G.GAME.hands[handname]) then
            return false
        end

        return Vegasstuff.compat.safe_poker_hand_visible_ref(handname)
    end
end
