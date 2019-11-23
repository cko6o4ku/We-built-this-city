local Event = require "utils.event"
local Global = require "utils.global"
local get_player_from_event = require "utils.get_player_from_event"

local poles = {}

Global.register({
  poles = poles,
}, function(global) 
  poles = global.poles 
end)




local function tick()

  if not poles["cave"] then 
    local found = game.surfaces["cave"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "electric-energy-interface",
      limit = 1
    })

    poles["cave"] = found[1]
  end

  if not poles["overworld"] then 
    local found = game.surfaces["overworld"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "electric-energy-interface",
      limit = 1
    })

    poles["overworld"] = found[1]
  end



  local cave      = poles["cave"]
  local overworld = poles["overworld"]

  if not cave or not overworld then return end
  if not cave.valid or not overworld.valid then return end


  local max_buffer = overworld.electric_buffer_size
  local drain = 10e8 -- 1 GJ
  local needed = max_buffer - cave.energy
  if cave.energy < max_buffer then
    local do_drain = needed <= drain and needed or drain

    if overworld.energy >= do_drain then
      overworld.energy = overworld.energy - do_drain
      cave.energy = cave.energy + math.ceil(overworld.energy)
    else
      cave.energy = cave.energy + math.ceil(overworld.energy)
      overworld.energy = 0
    end
  else 
    cave.energy = max_buffer
  end
end

local function built_entity(event)
  local entity = event.created_entity
  if not entity.valid then return end
  local player = get_player_from_event(event)
  local surface = entity.surface
  if surface.name ~= "cave" then return end
  if entity.name == "steam-engine" or entity.name == "steam-turbine" or entity.name == "lab" or entity.name == "rocket-silo" then 
    if not entity.valid then return end
    player.print("\""..entity.name.."\" Does not seem to work down here, thats strange!", {r = 1, g = 0, b = 0})
    entity.active = false
  end
end

Event.register(defines.events.on_tick, tick)
Event.register(defines.events.on_built_entity, built_entity)