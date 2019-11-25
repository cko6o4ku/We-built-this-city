local respawn_interval = 7200
local fish_respawner_water_tiles_per_fish = 32
local fish_respawner_max_respawnrate_per_chunk = 1

local valid_water_tiles = {
			"water",
			"deepwater",
			"water-green",
			"deepwater-green"
		}

local event = require 'utils.event'
local math_random = math.random

local function shuffle(tbl)
	local size = #tbl
		for i = size, 1, -1 do
			local rand = math_random(size)
			tbl[i], tbl[rand] = tbl[rand], tbl[i]
		end
	return tbl
end

local function get_surfaces()
	local surfaces = {}
	for _, player in pairs(game.connected_players) do
		if not surfaces[player.surface.index] then
			surfaces[player.surface.index] = player.surface
		end
	end
	return surfaces
end

local function create_new_fish_spawn_schedule()
	global.fish_respawn_chunk_schedule = {}

	local surfaces = get_surfaces()
	if #surfaces == 0 then return end

	for _, surface in pairs(surfaces) do
		for chunk in surface.get_chunks() do
			global.fish_respawn_chunk_schedule[#global.fish_respawn_chunk_schedule + 1] = {chunk = {x = chunk.x, y = chunk.y}, surface_index = surface.index}
		end
	end

	global.fish_respawn_chunk_schedule = shuffle(global.fish_respawn_chunk_schedule)

	return global.fish_respawn_chunk_schedule
end

local function respawn_fishes_in_chunk(schedule)
	local surface = game.surfaces[schedule.surface_index]
	local chunk = schedule.chunk
	local chunk_area = {{chunk.x * 32, chunk.y * 32}, {chunk.x * 32 + 32, chunk.y * 32 + 32}}

	local water_tiles = surface.find_tiles_filtered({area = chunk_area, name = valid_water_tiles})
	if #water_tiles < fish_respawner_water_tiles_per_fish then return end

	local chunk_fish_count = surface.count_entities_filtered({area = chunk_area, type = "fish"})

	local fish_to_spawn = math.floor((#water_tiles - (fish_respawner_water_tiles_per_fish * chunk_fish_count)) / fish_respawner_water_tiles_per_fish)
	if fish_to_spawn <= 0 then return end

	if fish_to_spawn > fish_respawner_max_respawnrate_per_chunk then fish_to_spawn = fish_respawner_max_respawnrate_per_chunk end

	water_tiles = shuffle(water_tiles)
	for _, tile in pairs(water_tiles) do
		if surface.can_place_entity({name = "fish", position = tile.position}) then
			surface.create_entity({name = "water-splash", position = tile.position})
			surface.create_entity({name = "fish", position = tile.position})
			fish_to_spawn = fish_to_spawn - 1
			if fish_to_spawn <= 0 then return end
		end
	end
end

local function on_tick()
	if global.dont_add_fish then return end
	local i = game.tick % respawn_interval
	if i == 0 then create_new_fish_spawn_schedule() return end
	if not global.fish_respawn_chunk_schedule[i] then return end
	respawn_fishes_in_chunk(global.fish_respawn_chunk_schedule[i])
	global.fish_respawn_chunk_schedule[i] = nil
end

event.add(defines.events.on_tick, on_tick)