return {
    descriptions = {
        Back = {
            b_vegasstuff_seized_deck = {
                name = "Seized Deck",
                text = {
                    "Start with an {C:attention}Eternal{}",
                    "{C:attention}Vega{} Joker",
                },
            },
            b_vegasstuff_solar_deck = {
                name = "Solar Deck",
                text = {
                    "{C:attention}Blind rewards{} become {C:attention}Astro Tags{}",
                    "Earn {C:money}$0{} and skip the {C:attention}Shop{}",
                    "{C:attention}Astro Tags{} open free {C:vegasstuff_geomancy}Astro Packs{}",
                },
            },
        },
        Joker = {
            j_vegasstuff_theseized = {
                name = "The Seized",
                text = {
                    "{C:inactive}No effect{}",
                },
                unlock = {
                    "Unlocked by default.",
                },
            },
            j_vegasstuff_vega = {
                name = "Vega",
                text = {
                    "After every {C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} cards used,",
                    "gain {C:attention}+#3#{} {C:attention}selection limit{}",
                    "{C:inactive}[#1#/#2#]{}",
                },
                unlock = {
                    "Unlocked by default.",
                },
            },
        },
        Enhanced = {
            m_vegasstuff_anaphase = {
                name = "Anaphase",
                text = {
                    "After this {C:attention}card{} is played",
                    "{C:attention}#2#{} times,",
                    "create a {C:attention}Base{} copy",
                    "{C:inactive}(#1#/#2#){}",
                },
            },
            m_vegasstuff_creased = {
                name = "Creased",
                text = {
                    "{C:attention}+#1#{} Hand Size",
                    "while held in {C:attention}hand{}",
                    "Loses that bonus when played",
                },
            },
            m_vegasstuff_dreamy = {
                name = "Dreamy",
                text = {
                    "{C:red}+#1#{} Mult per",
                    "{C:tarot}Tarot{} card used this run",
                },
            },
            m_vegasstuff_duality = {
                name = "Duality",
                text = {
                    "When scored, decrease",
                    "{C:attention}Blind size{} by {C:blue}#1#%{}",
                },
            },
            m_vegasstuff_midas = {
                name = "{C:enhanced}Midas{}",
                text = {
                    "Gain {C:money}$#1#{} when scored",
                    "{C:attention}Retriggers{} for each",
                    "other scored {C:enhanced}Midas{} card",
                },
            },
            m_vegasstuff_miniscule = {
                name = "Miniscule",
                text = {
                    "{C:inactive}Smaller",
                    "for no reason{}",
                },
            },
            m_vegasstuff_rusted = {
                name = "Rusted",
                text = {
                    "{C:blue}+#1# Chips{}",
                    "{C:attention}Held in hand{}: {C:red}+#2# Mult{}",
                    "{C:attention}Retrigger{} once if no",
                    "{C:enhanced}Rusted{} cards scored",
                },
            },
            m_vegasstuff_scoped = {
                name = "Scoped",
                text = {
                    "{X:red,C:white}X#1#{} Mult per",
                    "{C:dark_edition}Editioned{} {C:attention}Joker{}",
                    "{C:inactive}(Currently {X:red,C:white}X#2#{}{C:inactive}){}",
                },
            },
            m_vegasstuff_soggy = {
                name = "Soggy",
                text = {
                    "When scored, {C:attention}permanently{}",
                    "gain {C:blue}+#1#{} Chips",
                    "{C:attention}Held{} at end of round:",
                    "lose {C:blue}#2#{} Chips",
                    "{C:inactive}(Currently +#3#, minimum #4#){}",
                },
            },
            m_vegasstuff_stitched = {
                name = "Stitched",
                text = {
                    "{C:blue}#1#X{} base Chips",
                    "If {C:attention}2+{} {C:enhanced}Stitched{} cards",
                    "are scored, retrigger once",
                },
            },
            m_vegasstuff_tapered = {
                name = "Tapered",
                text = {
                    "If {C:attention}one{} {C:enhanced}Tapered{} card",
                    "is played {C:attention}alone{}, give",
                    "all cards in {C:attention}hand{} a {C:attention}random Seal{}",
                    "{C:inactive}(Does not overwrite seals){}",
                },
            },
            m_vegasstuff_toxin = {
                name = "Toxin",
                text = {
                    "{X:red,C:white}X#1#{} Mult when scored",
                    "{C:red}Destroyed{} after",
                    "{C:attention}#2#{} scores",
                },
            },
            m_vegasstuff_wartorn = {
                name = "War Torn",
                text = {
                    "Scored {C:attention}rank value{} gives",
                    "{C:red}Mult{} instead of {C:blue}Chips{}",
                },
            },
        },
        Edition = {
            e_vegasstuff_boric = {
                label = "Boric",
                name = "Boric",
                text = {
                    "While {C:attention}highlighted{}, gives",
                    "{C:attention}+1{} play and discard {C:attention}selection limit{}",
                },
            },
            e_vegasstuff_event_horizon = {
                label = "Event Horizon",
                name = "Event Horizon",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                    "{X:mult,C:white}+#2#X{} per played",
                    "{C:attention}unscored{} card",
                    "{X:mult,C:white}+#3#X{} per empty",
                    "{C:attention}consumable{} slot",
                },
            },
            e_vegasstuff_miniscule = {
                label = "Miniscule",
                name = "Miniscule",
                text = {
                    "{C:inactive}Smaller",
                    "for no reason{}",
                },
            },
            e_vegasstuff_planetarium_deluxe = {
                label = "Planetarium Deluxe",
                name = "Planetarium Deluxe",
                text = {
                    "{C:chips}+#3#{} Chips",
                    "{C:chips}+#1#{} Chips per",
                    "{C:vegasstuff_geomancy}Geomancy{} level",
                    "{C:mult}+#2#{} Mult per",
                    "{C:purple}Zodiac{} card used",
                },
            },
            e_vegasstuff_retrowave = {
                label = "Neon Jackpot",
                name = "Neon Jackpot",
                text = {
                    "Scored {C:attention}7s{} give",
                    "{C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult,",
                    "and {C:money}$#3#{}",
                },
            },
            e_vegasstuff_singularity_aquarium = {
                label = "Singularity Aquarium",
                name = "Singularity Aquarium",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                    "{X:mult,C:white}+#2#X{} per empty",
                    "{C:attention}consumable{} slot",
                    "Retrigger once per empty slot",
                    "{C:inactive}(max #3# retriggers){}",
                },
            },
            e_vegasstuff_supernova = {
                label = "Supernova",
                name = "Supernova",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                    "{X:mult,C:white}+#2#X{} per {C:vegasstuff_name_sol}Sol{} level",
                    "{X:mult,C:white}+#3#X{} per {C:vegasstuff_name_mars}Mars{} level",
                },
            },
        },
        Spectral = {
            c_vegasstuff_cwypid = {
                name = "Cwypid",
                text = {
                    "Create {C:attention}2{} {C:enhanced}Miniscule{}",
                    "copies of {C:attention}1{} {C:attention}selected card{}",
                },
            },
        },
        geomancy = {
            c_vegasstuff_croptid = {
                name = "Croptid",
                text = {
                    "Gain {C:money}$2{}",
                },
            },
            c_vegasstuff_jupiter = {
                name = "{C:vegasstuff_name_jupiter}Jupiter{}",
                text = {
                    "{C:attention}Permanently{} gain",
                    "{C:attention}+#1#{} {C:attention}consumable{} slots",
                    "{C:inactive}(Level #2#/#3#, Total +#4# slots){}",
                },
            },
            c_vegasstuff_luna = {
                name = "{C:vegasstuff_name_luna}Luna{}",
                text = {
                    "{C:attention}Permanently{} add {C:blue}+#1#{} Chips",
                    "to all cards in your {C:attention}deck{}",
                    "{C:inactive}(Level #2#/#4#, Total +#3# Chips){}",
                },
            },
            c_vegasstuff_mars = {
                name = "{C:vegasstuff_name_mars}Mars{}",
                text = {
                    "{C:attention}Permanently{} add {C:red}+#1#{} Mult",
                    "to all cards in your {C:attention}deck{}",
                    "{C:inactive}(Level #2#/#4#, Total +#3# Mult){}",
                },
            },
            c_vegasstuff_mercurius = {
                name = "{C:vegasstuff_name_mercurius}Mercurius{}",
                text = {
                    "After buying {C:attention}#1#{} {C:attention}consumables{},",
                    "the next {C:attention}consumable{} bought",
                    "becomes {C:dark_edition}Negative{}",
                    "{C:inactive}(Progress #2#/#1#, Level #3#/#4#){}",
                },
            },
            c_vegasstuff_neptunus = {
                name = "{C:vegasstuff_name_neptunus}Neptunus{}",
                text = {
                    "{C:attention}Permanently{} add {X:chips,C:white}X#1#{} Chips",
                    "to all cards in your {C:attention}deck{}",
                    "{C:inactive}(Level #2#/#3#, Total X#4# Chips){}",
                },
            },
            c_vegasstuff_pluto = {
                name = "{C:vegasstuff_name_pluto}Pluto{}",
                text = {
                    "{C:attention}Permanently{} add {X:red,C:white}X#1#{} Mult",
                    "to all cards in your {C:attention}deck{}",
                    "{C:inactive}(Level #2#/#3#, Total X#4# Mult){}",
                },
            },
            c_vegasstuff_saturnus = {
                name = "{C:vegasstuff_name_saturnus}Saturnus{}",
                text = {
                    "Increase {C:attention}interest{} by {C:money}+$#1#{}",
                    "Removes the {C:attention}interest cap{}",
                    "{C:inactive}(Level #2#/#4#, Total +$#3# interest){}",
                },
            },
            c_vegasstuff_sol = {
                name = "{C:vegasstuff_name_sol}Sol{}",
                text = {
                    "Gain {V:1}+#1# Ascended{} {C:attention}Power{}",
                    "{C:inactive}(Level #2#/#3#){}",
                },
            },
            c_vegasstuff_terra = {
                name = "{C:vegasstuff_name_terra}Terra{}",
                text = {
                    "{C:attention}Permanently{} gain {C:attention}+#1#{} {C:attention}hand size{}",
                    "{C:inactive}(Level #2#/#3#, Total +#4# hand size){}",
                },
            },
            c_vegasstuff_uranus = {
                name = "{C:vegasstuff_name_uranus}Uranus{}",
                text = {
                    "After buying {C:attention}#1#{} {C:attention}Jokers{},",
                    "the next {C:attention}Joker{} bought",
                    "becomes {C:dark_edition}Negative{}",
                    "{C:inactive}(Progress #2#/#1#, Level #3#/#4#){}",
                },
            },
            c_vegasstuff_venus = {
                name = "{C:vegasstuff_name_venus}Venus{}",
                text = {
                    "Earn {C:money}+$#1#{} from {C:attention}Blind payout{}",
                    "{C:inactive}(Level #2#/#4#, Total +$#3# payout){}",
                },
            },
        },
        zodiac = {
            c_vegasstuff_aquarius = {
                name = "{C:vegasstuff_name_aquarius}Aquarius{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Soggy{}",
                },
            },
            c_vegasstuff_aries = {
                name = "{C:vegasstuff_name_aries}Aries{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}War Torn{}",
                },
            },
            c_vegasstuff_cancer = {
                name = "{C:vegasstuff_name_cancer}Cancer{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Creased{}",
                },
            },
            c_vegasstuff_capricorn = {
                name = "{C:vegasstuff_name_capricorn}Capricorn{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Scoped{}",
                },
            },
            c_vegasstuff_gemini = {
                name = "{C:vegasstuff_name_gemini}Gemini{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Anaphase{}",
                },
            },
            c_vegasstuff_leo = {
                name = "{C:vegasstuff_name_leo}Leo{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Midas{}",
                },
            },
            c_vegasstuff_libra = {
                name = "{C:vegasstuff_name_libra}Libra{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Duality{}",
                },
            },
            c_vegasstuff_pisces = {
                name = "{C:vegasstuff_name_pisces}Pisces{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Dreamy{}",
                },
            },
            c_vegasstuff_sagittarius = {
                name = "{C:vegasstuff_name_sagittarius}Sagittarius{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Toxin{}",
                },
            },
            c_vegasstuff_scorpio = {
                name = "{C:vegasstuff_name_scorpio}Scorpio{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Tapered{}",
                },
            },
            c_vegasstuff_taurus = {
                name = "{C:vegasstuff_name_taurus}Taurus{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Rusted{}",
                },
            },
            c_vegasstuff_virgo = {
                name = "{C:vegasstuff_name_virgo}Virgo{}",
                text = {
                    "Enhance {C:attention}1{} {C:attention}selected card{} into {C:enhanced}Stitched{}",
                },
            },
        },
        RetroCode = {
            c_vegasstuff_ace = {
                name = "://ACE",
                text = {
                    "Select a {C:attention}playing card{}",
                    "Until {C:attention}end of round{}, it is",
                    "{C:attention}every suit{} and a {C:attention}face card{}",
                },
            },
            c_vegasstuff_alt_tab = {
                name = "://ALT_TAB",
                text = {
                    "Open a free random {C:attention}Booster Pack{}",
                    "Return with {C:blue}+#1#{} {C:attention}hand{}",
                    "and {C:red}+#2#{} {C:attention}discard{}",
                    "{C:attention}Halve{} the current {C:attention}Blind{}",
                    "{C:attention}Mega/Jumbo{} packs gain",
                    "{C:attention}+#3#{} {C:attention}pack selection{} this run",
                },
            },
            c_vegasstuff_bootloop = {
                name = "://BOOTLOOP",
                text = {
                    "Return {C:attention}hand{}, played, and",
                    "discarded cards to {C:attention}deck{}",
                    "Reset {C:blue}Hands{} and {C:red}Discards{},",
                    "then reboot {C:attention}#1#{} times",
                    "Each reboot saves a {C:attention}ghost hand{}",
                    "Your next played {C:attention}hand{} also",
                    "scores those {C:attention}ghost hands{}",
                },
            },
            c_vegasstuff_break = {
                name = ";//BREAK",
                text = {
                    "{C:attention}Immediately{} defeat the",
                    "current {C:attention}Blind{}",
                    "{C:money}Cash out{} normally, then gain",
                    "its {C:money}money{} and reward",
                    "{C:attention}Tag{} an extra time",
                    "{C:attention}Boss/Champion Blinds{} also",
                    "create a random {C:green}Retro Code{}",
                },
            },
            c_vegasstuff_build = {
                name = "://BUILD",
                text = {
                    "Select a {C:attention}Joker{}",
                    "Add {C:cry_code}+1{} to its",
                    "{C:cry_code}listed values{}",
                },
            },
            c_vegasstuff_buserr = {
                name = "://BUSERR",
                text = {
                    "The next played {C:attention}hand{}",
                    "retriggers its {C:attention}middle{} scoring card",
                    "{C:attention}1{} additional time",
                    "{C:inactive}(Random if there is no middle card){}",
                },
            },
            c_vegasstuff_cache = {
                name = "://CACHE",
                text = {
                    "Create copies of the last {C:attention}#1#{}",
                    "{C:attention}consumables{} used this run",
                    "Copies have {C:attention}#2#{} uses",
                    "{C:green}Retro Code{} copies become",
                    "{C:dark_edition}Negative{}",
                    "If both are {C:green}Retro Code{},",
                    "create an extra random {C:green}Retro Code{}",
                },
            },
            c_vegasstuff_cardinality = {
                name = "://CARDINALITY",
                text = {
                    "Let {C:attention}N{} be every {C:attention}card{} you own",
                    "Gain {C:attention}+N{} {C:attention}hand size{}",
                    "Gain {C:money}$N{}",
                    "Create {C:attention}N/#1#{} {C:dark_edition}Negative{}",
                    "{C:attention}Jokers{}, {C:attention}consumables{}, and {C:green}Retro Codes{}",
                    "Current {C:attention}Blind{} requirement",
                    "is divided by {C:attention}N{}",
                },
            },
            c_vegasstuff_const = {
                name = "://CONST",
                text = {
                    "Select {C:attention}1{} {C:attention}playing card{}",
                    "Its {C:attention}rank{} and {C:attention}suit{} become",
                    "{C:green}constant{} for the run",
                    "All current and future {C:attention}playing cards{}",
                    "become that {C:attention}rank{} and {C:attention}suit{}",
                    "The {C:attention}selected card{} becomes",
                    "{C:dark_edition}Polychrome{}, {C:attention}Steel{},",
                    "{C:red}Red Seal{}, {C:green}Rigged{}, and {C:green}Global{}",
                },
            },
            c_vegasstuff_ctrl_v = {
                name = "://CTRL_V",
                text = {
                    "Select {C:attention}anything{}",
                    "Paste {C:attention}#1#{} exact copies",
                    "Copies keep {C:dark_edition}editions{}, {C:attention}seals{},",
                    "{C:attention}stickers{}, and {C:cry_code}values{}",
                    "{C:attention}Full areas{} are expanded",
                    "instead of blocking the {C:attention}paste{}",
                },
            },
            c_vegasstuff_daemon = {
                name = "://DAEMON",
                text = {
                    "Start a {C:green}background process{}",
                    "for the rest of this {C:attention}Ante{}",
                    "At each {C:attention}Blind{}, run the first",
                    "available job:",
                    "draw to full {C:attention}hand{}, create a {C:attention}Joker{},",
                    "create a {C:attention}consumable{}, or add",
                    "{C:cry_code}+#1#{} {C:cry_code}listed values{}",
                    "to a random {C:attention}Joker{}",
                },
            },
            c_vegasstuff_env = {
                name = "://ENV",
                text = {
                    "Create a {C:green}global environment{}",
                    "until end of {C:attention}Ante{}",
                    "Created {C:attention}playing cards{} inherit your",
                    "{C:attention}deck{}'s most common {C:attention}rank{} and {C:attention}suit{}",
                    "Created {C:attention}Jokers{} inherit your",
                    "most common {C:attention}Joker rarity{}",
                    "Created {C:attention}consumables{} inherit your",
                    "most common {C:attention}consumable type{}",
                },
            },
            c_vegasstuff_exponent = {
                name = "://EXPONENT",
                text = {
                    "Multiply all owned {C:attention}Jokers{}",
                    "and {C:attention}consumables{}' {C:cry_code}listed values{}",
                    "by {C:attention}#1#x{}",
                    "Each use this run doubles",
                    "this {C:attention}multiplier{} again",
                    "Affected {C:attention}consumables{} gain",
                    "{C:attention}+#2#{} use",
                    "Affected {C:attention}Jokers{} become {C:dark_edition}Negative{}",
                },
            },
            c_vegasstuff_fork = {
                name = "://FORK",
                text = {
                    "Fork the current {C:attention}Blind{}",
                    "When defeated, {C:attention}duplicate{} its",
                    "{C:money}money{} and reward {C:attention}Tag{}",
                    "{C:attention}Boss Blind{} forks disable",
                    "the {C:attention}Boss{} after the first {C:attention}hand{}",
                    "{C:inactive}(Stackable){}",
                },
            },
            c_vegasstuff_fracture = {
                name = "://FRACTURE",
                text = {
                    "Divide the current {C:attention}Blind{} by {C:attention}2{}",
                    "Halve {C:attention}Shop prices{} for the rest",
                    "of the run",
                    "Each non-Legendary {C:attention}Joker{} creates",
                    "a {C:dark_edition}Negative{} copy with",
                    "halved {C:cry_code}listed values{}",
                    "Each {C:attention}consumable{} creates a",
                    "{C:dark_edition}Negative{} {C:attention}1-use{} copy",
                },
            },
            c_vegasstuff_hardlock = {
                name = "://HARDLOCK",
                text = {
                    "Select a {C:attention}Joker{} to become {C:dark_edition}Glitched{}",
                    "{C:cry_code}Double{} its {C:cry_code}listed values{} until",
                    "{C:attention}end of round{}, then {C:red}debuff{} it",
                    "for the next {C:attention}Blind{}",
                },
            },
            c_vegasstuff_hijack = {
                name = "://HIJACK",
                text = {
                    "Select a {C:attention}Joker{}",
                    "The next {C:attention}Boss Blind{} is disabled",
                    "Create a {C:dark_edition}Negative{} copy",
                    "of the {C:attention}selected Joker{}",
                },
            },
            c_vegasstuff_iloveyou = {
                name = "://ILOVEYOU",
                text = {
                    "Select a {C:attention}playing card{}",
                    "It becomes {C:dark_edition}Glitched{}",
                    "Copy its {C:dark_edition}edition{} to {C:attention}#1#{}",
                    "random cards in your {C:attention}deck{}",
                },
            },
            c_vegasstuff_index = {
                name = "://INDEX",
                text = {
                    "The next {C:attention}Booster Pack{} has",
                    "{C:attention}+#1#{} {C:attention}cards{}",
                    "Take {C:attention}every{} {C:attention}card{}",
                    "Taken {C:attention}cards{} become {C:dark_edition}Negative{}",
                },
            },
            c_vegasstuff_instance = {
                name = "://INSTANCE",
                text = {
                    "Select a {C:attention}Joker{}",
                    "Until end of {C:attention}Ante{}, future {C:attention}Jokers{}",
                    "become {C:green}instances{} of it:",
                    "copy {C:cry_code}listed values{}, {C:dark_edition}Edition{},",
                    "and {C:attention}stickers{} when possible",
                },
            },
            c_vegasstuff_join = {
                name = "://JOIN",
                text = {
                    "Select {C:attention}2{} {C:attention}playing cards{}",
                    "Swap their {C:attention}Enhancements{},",
                    "{C:attention}Editions{}, and {C:attention}Seals{}",
                },
            },
            c_vegasstuff_kludge = {
                name = "://KLUDGE",
                text = {
                    "Create a random {C:attention}Food Joker{}",
                    "Add {C:cry_code}+#1#{} {C:cry_code}listed values{}",
                    "to all {C:attention}Food Jokers{}",
                },
            },
            c_vegasstuff_link = {
                name = "://LINK",
                text = {
                    "Select cards to choose",
                    "a {C:attention}poker hand{}",
                    "Give it {C:red}+#1#{} Mult per {C:attention}Joker{}",
                    "and {C:blue}+#2#{} Chips per {C:attention}consumable{}",
                    "At {C:attention}#3#{} {C:attention}Jokers{}, level it up",
                    "At {C:attention}#4#{} {C:attention}consumables{}, create",
                    "a random {C:green}Retro Code{}",
                },
            },
            c_vegasstuff_pseudo = {
                name = "://PSEUDO",
                text = {
                    "Apply {C:green}Rigged{} to",
                    "every visible {C:attention}card{}",
                    "Give {C:attention}#1#{} random visible {C:attention}cards{}",
                    "an {C:dark_edition}Edition{}",
                    "Create a random {C:green}Retro Code{}",
                },
            },
            c_vegasstuff_push = {
                name = "://PUSH",
                text = {
                    "Destroy {C:attention}1{} {C:attention}selected Joker{}",
                    "Create {C:attention}2{} random {C:attention}Jokers{}",
                    "of one lower {C:attention}rarity{}",
                },
            },
            c_vegasstuff_replay = {
                name = "://REPLAY",
                text = {
                    "Execute your {C:green}run log{}:",
                    "Create {C:attention}1{} {C:dark_edition}Negative{} {C:attention}Joker{}",
                    "per {C:attention}Boss Blind{} defeated",
                    "Create {C:attention}1{} {C:dark_edition}Negative{} {C:attention}consumable{}",
                    "per {C:attention}Ante{} reached",
                    "Create {C:attention}1{} {C:dark_edition}Negative{} {C:green}Retro Code{}",
                    "per {C:green}Retro Code{} used",
                    "Gain {C:money}$#1#{} per {C:attention}card{} played",
                },
            },
            c_vegasstuff_rollback = {
                name = "://ROLLBACK",
                text = {
                    "Clear visible {C:red}debuffs{}",
                    "Return your {C:attention}discard pile{} to {C:attention}hand{}",
                    "Gain {C:blue}+#1#{} {C:attention}hand{}",
                },
            },
            c_vegasstuff_rom = {
                name = "://ROM",
                text = {
                    "Create a random {C:attention}Consumable{}",
                    "with {C:attention}#1#{} uses",
                },
            },
            c_vegasstuff_root = {
                name = "://ROOT",
                text = {
                    "Open the {C:green}ROOT shell{}",
                    "Use {C:attention}buttons{} for fast hacks",
                    "or run {C:green}Lua{} to create",
                    "{C:attention}custom buttons{}, forged {C:attention}Jokers{},",
                    "and {C:attention}scripted cards{}",
                },
            },
            c_vegasstuff_serial = {
                name = "://SERIAL",
                text = {
                    "Create {C:attention}#1#{} {C:attention}Voucher Tags{}",
                    "At {C:attention}Ante 4{} or later,",
                    "the first one",
                    "becomes a {C:cry_code}Golden Voucher Tag{}",
                },
            },
            c_vegasstuff_spawn = {
                name = "://SPAWN",
                text = {
                    "Select {C:attention}1{} {C:attention}playing card{}",
                    "Draw every card in your {C:attention}deck{}",
                    "with its {C:attention}rank{} or {C:attention}suit{}",
                    "This round, gain {C:attention}+#1#{}",
                    "play and discard {C:attention}selection limit{}",
                },
            },
            c_vegasstuff_trojan = {
                name = "://TROJAN",
                text = {
                    "Plant a {C:green}payload{} on the next {C:attention}Blind{}",
                    "When defeated, create {C:attention}#1#{}",
                    "random {C:green}Retro Code{}",
                    "{C:attention}Boss Blinds{} create {C:attention}#2#{} instead",
                },
            },
            c_vegasstuff_typedef = {
                name = "://TYPEDEF",
                text = {
                    "Select up to {C:attention}#1#{} {C:attention}playing cards{}",
                    "Until end of {C:attention}Ante{}, they become",
                    "a declared {C:green}type{}",
                    "When one scores, every other {C:attention}card{}",
                    "of that type scores from {C:attention}anywhere{}",
                },
            },
            c_vegasstuff_unlink = {
                name = "://UNLINK",
                text = {
                    "Select {C:attention}any{} {C:attention}card{}",
                    "{C:green}Unlink{} it from normal rules",
                    "{C:attention}Playing cards{} always score,",
                    "ignore {C:red}debuffs{}, and lose {C:attention}rank/suit{}",
                    "{C:attention}Jokers{} grant {C:attention}+1{} Joker slot",
                    "{C:attention}Consumables{} are not consumed",
                    "and create random {C:green}Retro Code{}",
                    "Every {C:attention}3{} {C:green}unlinked{} cards create",
                    "a random {C:dark_edition}Negative{} {C:green}Retro Code{}",
                },
            },
        },
        Voucher = {
            v_vegasstuff_geomancy_merchant = {
                name = "Geomancy Merchant",
                text = {
                    "{C:vegasstuff_geomancy}Geomancy{} cards",
                    "appear {C:attention}#1#X{}",
                    "more often in the {C:attention}Shop{}",
                },
            },
            v_vegasstuff_geomancy_tycoon = {
                name = "Geomancy Tycoon",
                text = {
                    "{C:vegasstuff_geomancy}Geomancy{} cards",
                    "appear {C:attention}#1#X{}",
                    "more often in the {C:attention}Shop{}",
                },
            },
            v_vegasstuff_zodiac_merchant = {
                name = "Zodiac Merchant",
                text = {
                    "{C:purple}Zodiac{} cards",
                    "appear {C:attention}#1#X{}",
                    "more often in the {C:attention}Shop{}",
                },
            },
            v_vegasstuff_zodiac_tycoon = {
                name = "Zodiac Tycoon",
                text = {
                    "{C:purple}Zodiac{} cards",
                    "appear {C:attention}#1#X{}",
                    "more often in the {C:attention}Shop{}",
                },
            },
        },
        Tag = {
            tag_vegasstuff_astro = {
                name = "Astro Tag",
                text = {
                    "Open a free {C:vegasstuff_geomancy}Astro Pack{}",
                    "{C:attention}Boss/Champion Blinds{}",
                    "open a {C:attention}Jumbo Pack{} instead",
                },
            },
            tag_vegasstuff_boric = {
                name = "Boric Tag",
                text = {
                    "Next {C:attention}base edition{} shop",
                    "{C:attention}Joker{} is free and becomes",
                    "{C:dark_edition}Boric{}",
                },
            },
            tag_vegasstuff_zodiac = {
                name = "Zodiac Tag",
                text = {
                    "Open a free {C:purple}Zodiac Pack{}",
                },
            },
        },
        Other = {
            cry_rigged = {
                name = "Rigged",
                text = {
                    "All {C:cry_code}listed{} probabilities",
                    "on this card are",
                    "{C:green}guaranteed{}",
                },
            },
            p_vegasstuff_geomancy_pack = {
                group_name = "Astro Pack",
                name = "Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_geomancy_pack2 = {
                group_name = "Astro Pack",
                name = "Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_geomancy_pack3 = {
                group_name = "Astro Pack",
                name = "Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_geomancy_pack4 = {
                group_name = "Astro Pack",
                name = "Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_jumbo_geomancy_pack = {
                group_name = "Astro Pack",
                name = "Jumbo Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_jumbo_geomancy_pack2 = {
                group_name = "Astro Pack",
                name = "Jumbo Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_jumbo_zodiac_pack = {
                group_name = "Zodiac Pack",
                name = "Jumbo Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_jumbozodiacpack2 = {
                group_name = "Zodiac Pack",
                name = "Jumbo Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_mega_geomancy_pack = {
                group_name = "Astro Pack",
                name = "Mega Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_mega_geomancy_pack2 = {
                group_name = "Astro Pack",
                name = "Mega Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_mega_zodiac_pack = {
                group_name = "Zodiac Pack",
                name = "Mega Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_megazodiacpack2 = {
                group_name = "Zodiac Pack",
                name = "Mega Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_mini_geomancy_pack = {
                group_name = "Astro Pack",
                name = "Mini Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_mini_geomancy_pack2 = {
                group_name = "Astro Pack",
                name = "Mini Astro Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_minizodiacpack = {
                group_name = "Zodiac Pack",
                name = "Mini Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_minizodiacpack2 = {
                group_name = "Zodiac Pack",
                name = "Mini Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_omega_pack = {
                group_name = "Omega Pack",
                name = "Omega Pack",
                text = {
                    "Choose from {C:attention}Omega{} cards",
                },
            },
            p_vegasstuff_pack_of_creation = {
                group_name = "Pack of Creation",
                name = "Pack of Creation",
                text = {
                    "Choose up to {C:attention}3{} of",
                    "{C:attention}3{} {C:attention}creation cards{}",
                    "{C:attention}70%{} {C:spectral}Pointer{}, {C:attention}30%{} {C:spectral}Gateway{}",
                },
            },
            p_vegasstuff_zodiac_pack = {
                group_name = "Zodiac Pack",
                name = "Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_zodiacpack2 = {
                group_name = "Zodiac Pack",
                name = "Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_zodiacpack3 = {
                group_name = "Zodiac Pack",
                name = "Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            p_vegasstuff_zodiacpack4 = {
                group_name = "Zodiac Pack",
                name = "Zodiac Pack",
                text = {
                    "Use up to {C:attention}#1#{} of",
                    "{C:attention}#2#{} {C:purple}Zodiac{} {C:attention}cards{}",
                },
            },
            undiscovered_retrocode = {
                name = "Undiscovered Retro Code",
                text = {
                    "Find this {C:green}Retro Code{} in",
                    "an old {C:attention}terminal{}",
                },
            },
            vegasstuff_cry_rigged_override = {
                name = "Rigged",
                text = {
                    "All {C:cry_code}listed{} probabilities",
                    "on this card are",
                    "{C:green}guaranteed{}",
                },
            },
        },
        Stake = {
            stake_vegasstuff_stake = {
                name = "Stake",
                text = {
                    "All {C:attention}playing cards{}",
                    "gain {C:dark_edition}Miniscule{}",
                },
            },
        },
        Sleeve = {
            sleeve_vegasstuff_solar = {
                name = "Solar Sleeve",
                text = {
                    "When not on {C:attention}Solar Deck{},",
                    "{C:attention}Astro Tags{} are",
                    "{C:attention}#1#X{} as common",
                },
            },
            sleeve_vegasstuff_solar_alt = {
                name = "Solar Sleeve",
                text = {
                    "On {C:attention}Solar Deck{},",
                    "{C:vegasstuff_geomancy}Geomancy{} values",
                    "per level are {C:attention}#1#X{}",
                },
            },
        },
        Partner = {
            pnr_vegasstuff_vega = {
                name = "Vega",
                text = {
                    "After every {C:attention}#2#{} {C:vegasstuff_geomancy}Geomancy{} cards used,",
                    "gain {C:attention}+#3#{} {C:attention}selection limit{}",
                    "{C:inactive}[#1#/#2#]{}",
                },
            },
        },
    },
    misc = {
        dictionary = {
            b_geomancy_cards = "Geomancy Cards",
            b_retrocode_cards = "Retro Code Cards",
            b_zodiac_cards = "Zodiac Cards",
            k_booster_group_p_vegasstuff_geomancy_pack = "Astro Pack",
            k_booster_group_p_vegasstuff_geomancy_pack2 = "Astro Pack",
            k_booster_group_p_vegasstuff_geomancy_pack3 = "Astro Pack",
            k_booster_group_p_vegasstuff_geomancy_pack4 = "Astro Pack",
            k_booster_group_p_vegasstuff_jumbo_geomancy_pack = "Astro Pack",
            k_booster_group_p_vegasstuff_jumbo_geomancy_pack2 = "Astro Pack",
            k_booster_group_p_vegasstuff_jumbo_zodiac_pack = "Zodiac Pack",
            k_booster_group_p_vegasstuff_jumbozodiacpack2 = "Zodiac Pack",
            k_booster_group_p_vegasstuff_mega_geomancy_pack = "Astro Pack",
            k_booster_group_p_vegasstuff_mega_geomancy_pack2 = "Astro Pack",
            k_booster_group_p_vegasstuff_mega_zodiac_pack = "Zodiac Pack",
            k_booster_group_p_vegasstuff_megazodiacpack2 = "Zodiac Pack",
            k_booster_group_p_vegasstuff_mini_geomancy_pack = "Astro Pack",
            k_booster_group_p_vegasstuff_mini_geomancy_pack2 = "Astro Pack",
            k_booster_group_p_vegasstuff_minizodiacpack = "Zodiac Pack",
            k_booster_group_p_vegasstuff_minizodiacpack2 = "Zodiac Pack",
            k_booster_group_p_vegasstuff_omega_pack = "Omega Pack",
            k_booster_group_p_vegasstuff_pack_of_creation = "Pack of Creation",
            k_booster_group_p_vegasstuff_zodiac_pack = "Zodiac Pack",
            k_booster_group_p_vegasstuff_zodiacpack2 = "Zodiac Pack",
            k_booster_group_p_vegasstuff_zodiacpack3 = "Zodiac Pack",
            k_booster_group_p_vegasstuff_zodiacpack4 = "Zodiac Pack",
            k_geomancy = "Geomancy",
            k_retrocode = "Retro Code",
            k_vegasstuff_astro_pack = "Astro Pack",
            k_vegasstuff_cry_exotic = "Exotic",
            k_vegasstuff_jen_transcendent = "Transcendent",
            k_vegasstuff_omega_pack = "Omega Pack",
            k_vegasstuff_pack_of_creation = "Pack of Creation",
            k_vegasstuff_zodiac_pack = "Zodiac Pack",
            k_zodiac = "Zodiac",
        },
        labels = {
            k_vegasstuff_cry_exotic = "Exotic",
            k_vegasstuff_jen_transcendent = "Transcendent",
            vegasstuff_boric = "Boric",
            vegasstuff_event_horizon = "Event Horizon",
            vegasstuff_miniscule = "Miniscule",
            vegasstuff_planetarium_deluxe = "Planetarium Deluxe",
            vegasstuff_retrowave = "Neon Jackpot",
            vegasstuff_singularity_aquarium = "Singularity Aquarium",
            vegasstuff_supernova = "Supernova",
        },
        suits_plural = {
            vegasstuff_Cups = "Chalices",
            vegasstuff_Pentacles = "Pentacles",
            vegasstuff_Swords = "Swords",
            vegasstuff_Wands = "Wands",
        },
        suits_singular = {
            vegasstuff_Cups = "Chalice",
            vegasstuff_Pentacles = "Pentacle",
            vegasstuff_Swords = "Sword",
            vegasstuff_Wands = "Wand",
        },
        quips = {
            pnr_vegasstuff_vega_1 = {
                "The stars are",
                "listening.",
            },
            pnr_vegasstuff_vega_2 = {
                "Asteres Planetai",
                "online.",
            },
            pnr_vegasstuff_vega_3 = {
                "Let's bend",
                "the hand limit.",
            },
        },
    },
}
