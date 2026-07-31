local font = renderer.setup_font("C:/windows/fonts/verdana.ttf", 13, 0)

local minimum_damage = ui.add_key_bind("MinimumDamage", "minimumdamage_key", 0, 1)
local minimum_damage_value = ui.add_slider_int("MinimumDamage Value", "minimumdamage_value", 0, 120, 1)

local m_iHealth = se.get_netvar("DT_BasePlayer", "m_iHealth")

local function on_create_move(cmd)
    local override = {
        MinimumDamage = { minimum_damage:is_active(), minimum_damage_value:get_value() }
    }

    local entities = entitylist.get_players(0)

    for i = 1, #entities do
        local index = entities[i]:get_index()

        if override.MinimumDamage[1] then
            ragebot.override_min_damage(index, override.MinimumDamage[2])
        end
    end
end

local function on_paint()
    local local_player = entitylist:get_local_player()
    local screen = engine.get_screen_size()

    if local_player:get_prop_int(m_iHealth) < 1 then
        return end

    if minimum_damage:is_active() then
        renderer.text('DMG', font, vec2_t.new(screen.x / 2 - 13, screen.y / 2 + 45), 13, color_t.new(240, 165, 20, 255))
    else
        renderer.text('DMG', font, vec2_t.new(screen.x / 2 - 13, screen.y / 2 + 45), 13, color_t.new(155, 0, 20, 255))
    end
end

client.register_callback('create_move', on_create_move)
client.register_callback("paint", on_paint)