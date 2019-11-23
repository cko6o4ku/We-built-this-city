local Event = require "utils.event"
local Global = require "utils.global"

local validate_player = require "utils.validate_player"
local chests = {}
local inventories = {}
local cooldowns = {}

Global.register({
  cooldowns = cooldowns
}, function(global)
  cooldowns = global.cooldowns
end)



Global.register({
  chests = chests,
  inventories = inventories
}, function(global) 
  chests = global.chests 
  inventories = global.inventories
end)



local function check_player_ports(event)
  for _, player in pairs(game.connected_players) do
    if not validate_player(player) then goto continue end
    
    if not cooldowns[player.name] then
      cooldowns[player.name] = game.tick
    end
    
    if cooldowns[player.name] - game.tick > 0 then goto continue end

    if player.surface.find_entity("player-port", player.position) then
      local surface_name = player.surface.name --== "surface_cave_chest" and "surface_cave_chest" or "surface_cave_chest"
      local pos = surface_name == "surface_cave_chest" and {-1, -8} or {1, -4}
      local safe_pos = game.surfaces[surface_name].find_non_colliding_position("character", pos, 20, 1)
      if safe_pos then
        player.teleport(safe_pos, surface_name)
      else
        player.teleport({0, -3}, surface_name)
      end
      cooldowns[player.name] = game.tick + 60 * 5
    end

    ::continue::
  end
end

local function built_entity(event)
  local entity = event.created_entity
  if not entity or not entity.valid then return end
  if entity.name ~= "player-port" then return end
  
  entity.minable = false
  entity.destructible = false
  entity.operable = false
  

  local surface = entity.surface
end

local function tick()
  if not chests["surface_cave_chest"] then 
    local found = game.surfaces["cave_miner"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "compilatron-chest",
      limit = 1
    })

    chests["surface_cave_chest"] = found[1]
  end

  if not chests["surface_cave_chest"] then 
    local found = game.surfaces["tree_miner"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "compilatron-chest",
      limit = 1
    })

    chests["surface_cave_chest"] = found[1]
  end



  local surface_cave_chest      = chests["surface_cave_chest"]
  local surface_cave_chest = chests["surface_cave_chest"]

  if not surface_cave_chest or not surface_cave_chest then return end
  if not surface_cave_chest.valid or not surface_cave_chest.valid then return end

  local ci = surface_cave_chest.get_inventory(defines.inventory.chest)
  local oi = surface_cave_chest.get_inventory(defines.inventory.chest)

  cc = ci.get_contents()
  oc = oi.get_contents()

  local inserted = { }
  for name, count in pairs(cc) do
    inserted[name] = oi.insert{ name = name, count = count }
  end
  
  for name, count in pairs(inserted) do
    if count > 0 then
      ci.remove{ name = name, count = count }
    end
  end
  

  
end

Event.register(defines.events.on_tick, tick)

Event.on_nth_tick(60, check_player_ports)
Event.register(defines.events.on_built_entity, built_entity)