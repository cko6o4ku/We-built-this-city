require 'util'
local Global = require 'utils.global'
local Event = require 'utils.event'
local wbtc_surface_name = 'wbtc'

local Public = {}

local global_data = {
    surface = nil,
    spawn_position = nil,
    island = false,
    surface_name = wbtc_surface_name
}

Global.register(
    global_data,
    function(tbl)
        global_data = tbl
    end
)

function Public.create_surface()
	local map_gen_settings =  game.surfaces["nauvis"].map_gen_settings

	if (global_data.island) then
	    map_gen_settings.property_expression_names.elevation = "0_17-island"
	end

	if not global_data.surface then
		global_data.surface = game.create_surface(wbtc_surface_name, map_gen_settings).index
	end

	local surface = game.surfaces[global_data.surface]

	surface.request_to_generate_chunks({0,0}, 2)
	surface.force_generate_chunk_requests()

	local p = surface.find_non_colliding_position("character-corpse", {0,-22}, 2, 2)
	surface.create_entity({name = "character-corpse", position = p})

	game.forces.player.technologies["landfill"].enabled = false
	game.forces.player.technologies["optics"].researched = true
	game.forces.player.set_spawn_position({0, 0}, surface)
	global_data.spawn_position = {0, 0}

	--surface.ticks_per_day = surface.ticks_per_day * 2
	--surface.min_brightness = 0.08
	--surface.daytime = 0.7
end

function Public.get_surface()
    return global_data.surface
end

function Public.get_surface_name()
    return global_data.surface_name
end

function Public.set_spawn_pos(var)
    global_data.spawn_position = var
end

function Public.set_island(var)
    global_data.island = var
end

Event.on_init(Public.create_surface)

return Public