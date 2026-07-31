local CI = ui.add_color_edit("Impact Color", "clienti", true, color_t.new(255, 0, 0, 80))
local SI = ui.add_color_edit("Color Server", "serveri", true, color_t.new(0, 0, 255, 80))

local function draw()     
    ffi.cdef[[
        struct vec3_t { float x, y, z; };
        typedef void(__thiscall* add_box_overlay_t)(void*, const struct vec3_t&, const struct vec3_t&, const struct vec3_t&, struct vec3_t const&, int, int, int, int, float);
    ]]

    local voidptr = ffi.typeof('void***')

    local debug_overlay = ffi.cast(voidptr, se.create_interface('engine.dll', 'VDebugOverlay004'))
    local add_box_overlay = ffi.cast('add_box_overlay_t', debug_overlay[0][1])

    local function draw_impact(x, y, z, color)
    local duration = 15

    local position = ffi.new('struct vec3_t')
    position.x = x; position.y = y; position.z = z
    local mins = ffi.new('struct vec3_t')
    mins.x = -4; mins.y = -4; mins.z = -4;
    local maxs = ffi.new('struct vec3_t')
    maxs.x = 4; maxs.y = 4; maxs.z = 4;
    local ori = ffi.new('struct vec3_t')
    mins.x = 0; mins.y = 0; mins.z = 0;

    add_box_overlay(debug_overlay, position, mins, maxs, ori, color.r, color.g, color.b, color.a, duration)
    end

    local function on_bullet_impact(event)
        if event:get_name() ~= 'bullet_impact' then
            return
        end

        local userid = engine.get_player_for_user_id(event:get_int('userid', 0))
        local me = engine.get_local_player()

        if me ~= userid then
            return
        end

        draw_impact(event:get_float('x', 0), event:get_float('y', 0), event:get_float('z', 0), SI:get_value())
    end

    local function on_shot_fired(shot)
        draw_impact(shot.aim_point.x, shot.aim_point.y, shot.aim_point.z, CI:get_value())
    end

    client.register_callback('shot_fired', on_shot_fired)
    client.register_callback('fire_game_event', on_bullet_impact)
end
client.register_callback('paint', draw)