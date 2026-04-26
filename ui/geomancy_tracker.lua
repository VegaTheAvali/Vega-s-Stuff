local GEOMANCY_TRACKED_CARDS = {
    { key = "sol", name = "Sol" },
    { key = "terra", name = "Terra" },
    { key = "mars", name = "Mars" },
    { key = "luna", name = "Luna" },
    { key = "neptunus", name = "Neptunus" },
    { key = "venus", name = "Venus" },
    { key = "pluto", name = "Pluto" },
    { key = "mercurius", name = "Mercurius" },
    { key = "saturnus", name = "Saturnus" },
    { key = "uranus", name = "Uranus" },
    { key = "jupiter", name = "Jupiter" },
}

G.FUNCS = G.FUNCS or {}

local function geomancy_center(card_key)
    return G and G.P_CENTERS and G.P_CENTERS["c_vegasstuff_" .. card_key]
end

local function geomancy_level(entry)
    if not (Vegasstuff and Vegasstuff.get_geomancy_level and Vegasstuff.get_geomancy_max_level) then
        return 0
    end

    local center = geomancy_center(entry.key)
    return math.min(
        Vegasstuff.get_geomancy_max_level(center or entry),
        Vegasstuff.get_geomancy_level(entry.key)
    )
end

local function geomancy_active_cards()
    local active = {}
    for _, entry in ipairs(GEOMANCY_TRACKED_CARDS) do
        local level = geomancy_level(entry)
        if level > 0 then
            local display_entry = {}
            for key, value in pairs(entry) do
                display_entry[key] = value
            end
            display_entry.level = level
            active[#active + 1] = display_entry
        end
    end
    return active
end

local function geomancy_card_rows(cards)
    local card_scale = 0.72
    local rows = {}
    local max_per_row = 5

    for start_index = 1, #cards, max_per_row do
        local row_cards = {}
        for index = start_index, math.min(start_index + max_per_row - 1, #cards) do
            row_cards[#row_cards + 1] = cards[index]
        end

        local area = CardArea(
            0,
            0,
            #row_cards * G.CARD_W * card_scale,
            G.CARD_H * card_scale,
            {
                card_limit = #row_cards,
                type = "title_2",
                highlight_limit = 0,
                collection = true
            }
        )

        for _, entry in ipairs(row_cards) do
            local center = geomancy_center(entry.key)
            if center then
                local card = Card(
                    0,
                    0,
                    G.CARD_W * card_scale,
                    G.CARD_H * card_scale,
                    nil,
                    center,
                    { bypass_discovery_center = true, bypass_discovery_ui = true, bypass_lock = true }
                )
                card:set_sprites(center)
                card:start_materialize(nil, true)
                area:emplace(card)
            end
        end

        rows[#rows + 1] = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04, no_fill = true },
            nodes = {
                { n = G.UIT.O, config = { object = area } }
            }
        }
    end

    return rows
end

function create_UIBox_vegasstuff_geomancy_tracker()
    local active_cards = geomancy_active_cards()
    local has_active_cards = #active_cards > 0

    local card_content = has_active_cards and {
        {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = geomancy_card_rows(active_cards)
                }
            }
        }
    } or {
        {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.15, colour = G.C.BLACK, r = 1, emboss = 0.05, minw = 4.8, minh = 1 },
            nodes = {
                {
                    n = G.UIT.O,
                    config = {
                        object = DynaText({
                            string = { "No active Geomancy cards" },
                            colours = { G.C.UI.TEXT_LIGHT },
                            bump = true,
                            scale = 0.45
                        })
                    }
                }
            }
        }
    }

    local menu_nodes = {
        {
            n = G.UIT.R,
            config = { align = "cm" },
            nodes = {
                {
                    n = G.UIT.O,
                    config = {
                        object = DynaText({
                            string = { "Geomancy Levels" },
                            colours = { G.C.UI.TEXT_LIGHT },
                            bump = true,
                            scale = 0.55
                        })
                    }
                }
            }
        },
        { n = G.UIT.R, config = { align = "cm", minh = 0.25 }, nodes = {} }
    }

    for _, node in ipairs(card_content) do
        menu_nodes[#menu_nodes + 1] = node
    end

    menu_nodes[#menu_nodes + 1] = {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.1 },
        nodes = {
            UIBox_button({
                button = "exit_overlay_menu",
                label = { "Back" },
                minw = 3.2,
                colour = HEX("ff9352")
            })
        }
    }

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            colour = G.C.UI.TRANSPARENT_DARK,
            r = 0.1,
            padding = 0.05,
            emboss = 0.05
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    colour = darken(G.C.UI.BACKGROUND_DARK, 0.15),
                    outline = 1.5,
                    outline_colour = G.C.GREY,
                    r = 0.1,
                    padding = 0.15
                },
                nodes = menu_nodes
            }
        }
    }
end

G.FUNCS.vegasstuff_geomancy_tracker = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu({
        definition = create_UIBox_vegasstuff_geomancy_tracker()
    })
end

function vegasstuff_geomancy_hud_button(scale)
    scale = scale or 0.45
    return {
        n = G.UIT.R,
        config = {
            align = "cm",
            minh = 1.2,
            minw = 1.5,
            padding = 0.05,
            r = 0.1,
            hover = true,
            colour = HEX("ff9352"),
            button = "vegasstuff_geomancy_tracker",
            shadow = true
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, maxw = 1.4 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Asteres", scale = 0.75 * scale, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0, maxw = 1.4 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Planetai", scale = 0.65 * scale, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                }
            }
        }
    }
end
