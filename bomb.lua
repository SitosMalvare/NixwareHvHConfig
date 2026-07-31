--CPlantedC4

local font = renderer.setup_font( "C:/Windows/Fonts/Calibril.ttf", 18, 1 )
local font2 = renderer.setup_font( "C:/Windows/Fonts/Calibril.ttf", 36, 1 )
local font_icons = renderer.setup_font( "C:/windows/fonts/csgo_icons.ttf", 36, 0 )

local screen_size = engine.get_screen_size( )
local offsets = 
{
	m_flC4Blow = se.get_netvar( "DT_PlantedC4", "m_flC4Blow" ),
	m_flDefuseCountDown = se.get_netvar( "DT_PlantedC4", "m_flDefuseCountDown" ),
	m_flTimerLength = se.get_netvar( "DT_PlantedC4", "m_flTimerLength" ),
	m_hBombDefuser = se.get_netvar( "DT_PlantedC4", "m_hBombDefuser" ),
	m_bStartedArming = se.get_netvar( "DT_WeaponC4", "m_bStartedArming" ),
	m_fArmedTime = se.get_netvar( "DT_WeaponC4", "m_fArmedTime" ),

	m_bombsiteCenterA = se.get_netvar( "DT_CSPlayerResource", "m_bombsiteCenterA" ),
	m_bombsiteCenterB = se.get_netvar( "DT_CSPlayerResource", "m_bombsiteCenterB" ),
	m_hOwnerEntity = se.get_netvar( "DT_BaseEntity", "m_hOwnerEntity" )
}

local tbomb_site = nil
local function render_planted_bomb( bomb )
	local time_to_defuse = ( globalvars.get_current_time( ) - bomb:get_prop_float( offsets.m_flDefuseCountDown ) ) * -1
	local time_to_explosion = ( globalvars.get_current_time( ) - bomb:get_prop_float( offsets.m_flC4Blow ) ) * -1
	local c4_blowtime_l = bomb:get_prop_float( offsets.m_flTimerLength )

	if time_to_explosion > 0.0
	then
		local player_resource = entitylist.get_entities_by_class( "CCSPlayerResource" )
		if #player_resource == 1
		then
			local a_ = player_resource[1]:get_prop_vector( offsets.m_bombsiteCenterA )
			local b_ = player_resource[1]:get_prop_vector( offsets.m_bombsiteCenterB )

			local origin = bomb:get_prop_vector( 0x138 )
			if origin and a_ and b_
			then
				bomb_site = a_:dist_to( origin ) > b_:dist_to( origin ) and "B" or "A"
			else
				bomb_site = "?"
			end
			local size = renderer.get_text_size( font2, 36, "Plant: " )
			renderer.text( "Plant: ", font2, vec2_t.new( 5, 30 ), 36, color_t.new( 236, 240, 241, 255 ) )

			local can_defuse = time_to_explosion > time_to_defuse 	
			renderer.text( string.format("%s (%.1fs)", bomb_site, time_to_explosion ), font2, vec2_t.new( 5 + size.x, 30 ), 36, can_defuse and color_t.new( 46, 204, 113, 255 ) or color_t.new( 231, 76, 60, 190 ) )
		end

		renderer.text( string.format( "%.1f", time_to_explosion ), font, vec2_t.new( screen_size.x * ( time_to_explosion / c4_blowtime_l ), 15 ), 18, color_t.new(  236, 240, 241, 255 ) )
		renderer.rect_filled( vec2_t.new( 0, 0 ), vec2_t.new( screen_size.x, 15 ), color_t.new( 50, 50, 50, 120 ) )
		renderer.rect_filled( vec2_t.new( 0, 0 ), vec2_t.new( screen_size.x * ( time_to_explosion / c4_blowtime_l ), 15 ), color_t.new( 231, 76, 60, 190 ) )

		local box = bomb:get_bbox( )
		if box ~= nil
		then
			local size = renderer.get_text_size( font_icons, 36, "M" )
			renderer.text( "M", font_icons, vec2_t.new( box.left + ( box.right - box.left ) / 2, box.bottom + ( box.top - box.bottom ) / 2 ), 36, color_t.new( 231, 76, 60, 255 ) )
			renderer.text( string.format( "BOMB: %.1fs", time_to_explosion ), font, vec2_t.new( box.left + ( box.right - box.left ) / 2, box.bottom + size.y + 2 ), 18, color_t.new( 231, 76, 60, 255 ) )
		end

		if time_to_defuse > 0.0 and bomb:get_prop_int( offsets.m_hBombDefuser ) ~= -1
		then
			local can_defuse = time_to_explosion > time_to_defuse 
			renderer.text( string.format( "%.1f", time_to_defuse ), font, vec2_t.new( screen_size.x * ( time_to_defuse / c4_blowtime_l ) + 5, 15 ), 18, can_defuse and color_t.new( 52, 152, 219, 255 ) or color_t.new( 231, 76, 60, 255 ) )
			renderer.rect_filled( vec2_t.new( 0, 15 ), vec2_t.new( screen_size.x * ( time_to_defuse / c4_blowtime_l ), 30 ), can_defuse and color_t.new( 52, 152, 219, 190 ) or color_t.new( 231, 76, 60, 190 ) )
		end
	end
end

local function render_bomb_being_planted( bomb )
	local is_planting = bomb:get_prop_bool( offsets.m_bStartedArming )
	local pl_t = bomb:get_prop_float( offsets.m_fArmedTime )
	local plant_time = ( globalvars.get_current_time( ) - pl_t ) * -1
	if plant_time > 0.0 and is_planting 
	then 
		renderer.rect_filled( vec2_t.new( 0, 0 ), vec2_t.new( screen_size.x, 15 ), color_t.new( 50, 50, 50, 120 ) )
		renderer.rect_filled( vec2_t.new( 0, 0 ), vec2_t.new( screen_size.x * ( ( 3 - plant_time ) / 3 ), 15 ), color_t.new( 241, 196, 15, 190 ) )
		renderer.text( string.format( "%.1f", plant_time ), font, vec2_t.new( screen_size.x * ( ( 3 - plant_time ) / 3 ) + 5, 0 ), 18, color_t.new( 236, 240, 241, 255 ) )

		local bomb_site = tbomb_site ~= nil and tbomb_site.site or "?"
		local size = renderer.get_text_size( font2, 36, "Bomb is being planted: " )
		renderer.text( "Bomb is being planted: ", font2, vec2_t.new( 5, 30 ), 36, color_t.new( 236, 240, 241, 255 ) )
		renderer.text( string.format("%s (%.1fs)", bomb_site, plant_time ), font2, vec2_t.new( 5 + size.x, 30 ), 36, color_t.new( 231, 76, 60, 190 ) )
		return true
	else
		local owner = bomb:get_prop_int( offsets.m_hOwnerEntity )
		if owner == -1
		then
			local box = bomb:get_bbox( )
			if box ~= nil
			then
				renderer.text( "M", font_icons, vec2_t.new( box.left + ( box.right - box.left ) / 2, box.bottom + ( box.top - box.bottom ) / 2 ), 36, color_t.new( 231, 76, 60, 255 ) )
				return true
			end
		end
	end
	return false
end

client.register_callback( "paint", function( )
	local me = entitylist.get_local_player( )

	if not me then return end

	local bombs_planted = entitylist.get_entities_by_class( "CPlantedC4" )
	if #bombs_planted == 1 
	then 
		render_planted_bomb( bombs_planted[1] )
	else
		local bombs = entitylist.get_entities_by_class_id( 34 )
		if #bombs >= 1
		then 
			if not render_bomb_being_planted( bombs[1] )
			then
				if tbomb_site ~= nil and ( globalvars.get_real_time( ) - tbomb_site.time <= 10.0 )
				then
					renderer.text( "Bomb Location: ", font2, vec2_t.new( 5, 30 ), 36, color_t.new( 236, 240, 241, 255 ) )
					local size = renderer.get_text_size( font2, 36, "Bomb Location: " )
					renderer.text( tbomb_site.site, font2, vec2_t.new( 5 + size.x, 30 ), 36, color_t.new( 231, 76, 60, 190 ) )
				end
			end
		else
			
		end
	end
end )

se.register_event( "enter_bombzone" )
se.register_event( "round_start" )
se.register_event( "round_end" )

client.register_callback( "fire_game_event", function( event )
	local event_name = event:get_name( ) 
	if event_name == "round_start" or event_name == "round_end"
	then
		tbomb_site = nil
	elseif event_name == "enter_bombzone" --and event:get_bool( "hasbomb" ) and not event:get_bool( "isplanted" )
	then
		if not event:get_bool( "hasbomb", false )
		then
			return
		end
		if event:get_bool( "isplanted", true )
		then
			return
		end
		local uid = event:get_int( "userid", -1 )
		if uid ~= -1
		then
			local entity = entitylist.get_entity_by_index( engine.get_player_for_user_id( uid ) )
			local origin = entity:get_prop_vector( 0x138 )
			if origin
			then
				local player_resource = entitylist.get_entities_by_class( "CCSPlayerResource" )
				if #player_resource == 1
				then
					local a_ = player_resource[1]:get_prop_vector( offsets.m_bombsiteCenterA )
					local b_ = player_resource[1]:get_prop_vector( offsets.m_bombsiteCenterB )

					tbomb_site = { site = ( a_:dist_to( origin ) > b_:dist_to( origin ) ) and "B" or "A", time = globalvars.get_real_time( ) }
				end
			end
		end
	end
end)