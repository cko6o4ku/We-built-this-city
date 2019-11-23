local Event = require "utils.event"
local Global = require "utils.global"

local chests = {}
local inventories = {}

Global.register({
  chests = chests,
  inventories = inventories
}, function(global) 
  chests = global.chests 
  inventories = global.inventories
end)






local function tick()

  if not chests["cave"] then 
    local found = game.surfaces["cave"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "compilatron-chest",
      limit = 1
    })

    chests["cave"] = found[1]
  end

  if not chests["overworld"] then 
    local found = game.surfaces["overworld"].find_entities_filtered({
      area = {{-10, -10}, {10, 10}}, 
      name = "compilatron-chest",
      limit = 1
    })

    chests["overworld"] = found[1]
  end



  local cave      = chests["cave"]
  local overworld = chests["overworld"]

  if not cave or not overworld then return end
  if not cave.valid or not overworld.valid then return end

  local ci = cave.get_inventory(defines.inventory.chest)
  local oi = overworld.get_inventory(defines.inventory.chest)

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