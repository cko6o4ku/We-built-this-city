local Event = require 'utils.event'
local surface_index = require 'utils.surface'.get_surface()
local surface_name = require 'utils.surface'.get_surface_name()

local Global = require 'utils.global'

local Public = {}

--basic interval for checks
local timeinterval = 2700 --2700 is 45 seconds at 60 UPS
--how many chunks to process in a tick
--todo: make config option
local processchunk = 5

--states
local IDLE = 1
local BASE_SEARCH = 2
local ATTACKING = 3

local math_random = math.random
local insert = table.insert
local remove = table.remove

local this = {
	bases = {},
	chunklist = {},
	groups = {},
	state = IDLE,
	lastattack = 0,
	c_index = 1
}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

function Public.get_table()
    return this
end

Event.on_init(function()
	if game.tick > 0 then
		Public.findchunks()
	end
end)

Event.add(defines.events.on_tick, function(event)
	if event.tick % timeinterval == 0 then
		if not game.surfaces[surface_name].darkness then return end
		if game.surfaces[surface_name].darkness > 0.5
			and this.state == IDLE
			and event.tick >= this.lastattack + timeinterval
			and math_random() > 0.5
		then
			--	Search for bases, then attack
			this.state = BASE_SEARCH
			game.surfaces[surface_name].print("entering attack mode")
		end
	end
	if event.tick % 120 == 0 then
		if game.surfaces[surface_name].darkness < 0.5  then
			for _, group in pairs(this.groups) do
				if group and group.valid == true and group.state == defines.group_state.moving then
					game.surfaces[surface_name].print("ordering stop " .. tostring(event.tick))
					group.set_command({
						type = defines.command.stop,
						ticks_to_wait = 120*1,
						distraction = defines.distraction.by_enemy
					})
				elseif group == nil or group.valid == false then
					remove(this.groups, _)
				end
			end
		elseif game.surfaces[surface_name].darkness >= 0.5 then

		end
	end
	if this.state == BASE_SEARCH then
		-- This is called every tick while in this state
		-- But only a small amount of work is done per call.
		-- State will change when it's finished.
		Public.findbases()
	elseif this.state == ATTACKING then
		Public.attack()
	end
end)

Event.add(defines.events.on_chunk_generated, function(event)
	-- Manually rebuilding the chunk list with findchunks() is relatively costly.
	-- So we'll track when new chunks are generated and just add them on.
	-- NOTE: The game's debug menu can show potentially hundreds of ungenerated chunks
	-- It's normal for this count to lag behind chunks in the debug menu.
	if event.surface == game.surfaces[surface_name] then
		local chunk = {}
		local coords = event.area.left_top
		chunk.x = coords.x+16
		chunk.y = coords.y+16
		insert(this.chunklist, chunk)
	end
end)

Event.add(defines.events.on_unit_group_created, function(event)
	if event.group.force.name == "enemy" then
		insert(this.groups, event.group)
		game.surfaces[surface_name].print("Group added " .. tostring(#this.groups))
	end
end)

function Public.attack()
	local maxindex = #this.bases
	local surface = game.surfaces[surface_name]
	for i=this.c_index, this.c_index+processchunk, 1 do
		if i > maxindex then
			-- we're done here
			this.state = IDLE
			break
		end
		if math_random() < surface.darkness then
			local base = this.bases[i]
			local group=surface.create_unit_group{position=base}
			for _, biter in ipairs(surface.find_enemy_units(base, 16)) do
				if biter.force.name == "enemy" then
					group.add_member(biter)
				end
			end
			if #group.members==0 then
				group.destroy()
			else
				--autonomous groups will attack polluted areas independently
				group.set_autonomous()
				game.surfaces[surface_name].print("sending biters")
				group.set_command{ type=defines.command.attack_area, destination=game.players[1].position, radius=200, distraction=defines.distraction.by_anything }
			end
		end
	end
	this.c_index = this.c_index + processchunk
	--Reset if we're moving to the next state.
	if this.state == IDLE then
		this.c_index = 1
		this.lastattack = game.tick
	end
end

function Public.findbases()
	if this.c_index == 1 then
		this.bases = {}
	end
	local maxindex = #this.chunklist
	for i=this.c_index, this.c_index+processchunk, 1 do
		if i > maxindex then
			-- we're done with the search
			this.state = ATTACKING
			break
		end
		if game.surfaces[surface_name].get_pollution(this.chunklist[i]) > 0.1 then
			local chunkcoord = this.chunklist[i]
			if (game.surfaces[surface_name].count_entities_filtered{area={{chunkcoord.x-16, chunkcoord.y-16},{chunkcoord.x+16, chunkcoord.y+16}},
					type = "unit-spawner"}) > 0 then
				insert(this.bases,chunkcoord)
			end
		end
	end
	this.c_index = this.c_index + processchunk
	--Reset if we're moving to the next state.
	if this.state == ATTACKING then
		this.c_index = 1
		Public.shuffleTable(this.bases)
		game.surfaces[surface_name].print("bases added: " .. tostring(#this.bases))
	end
end

function Public.findchunks()
	this.chunklist = {}
	for coords in game.surfaces[surface_name].get_chunks() do
		if game.surfaces[surface_name].is_chunk_generated(coords) then
			insert(this.chunklist, Public.chunk_to_tiles(coords))
		end
	end
	game.surfaces[surface_name].print("chunks added: " .. tostring(#this.chunklist))
end

function Public.chunk_to_tiles(chunk) --transform chunk coords to coords of it's middle tile
	local tile={}
	tile.x=math.floor((chunk.x+0.5)*32)
	tile.y=math.floor((chunk.y+0.5)*32)
	return tile
end


function Public.shuffleTable( t )
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    for i = iterations, 2, -1 do
        j = math_random(i)
        t[i], t[j] = t[j], t[i]
    end
end

return Public