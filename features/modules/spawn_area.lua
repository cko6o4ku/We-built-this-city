local event = require 'utils.event' 

local tile_positions = {
    {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
    {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
}

local entitys = {
    {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
    {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
    {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3},
    {"iron-chest",-2,-6},{"iron-chest",-2,-5},{"iron-chest",2,-6},{"iron-chest",2,-5},{"iron-chest",2,5},{"iron-chest",2,6},{"iron-chest",-2,5},{"iron-chest",-2,6},
    {"solar-panel",-5,-5},{"solar-panel",5,-5},{"solar-panel",5,5},{"solar-panel",-5,5}
}

local global_offset = {x=0,y=0}
local decon_radius = 15
local decon_tile = 'refined-concrete'
local p_radius = 20
local p_tile = 'stone-path'


function spawn_on_chunk_generated(event)
    if not global.spawn_generated then
        local surface = game.surfaces[2]
        local offset = {x=-0,y=0}
        local base_tiles = {}
        local tiles = {}
            for x = -p_radius-5, p_radius+5 do
                for y = -p_radius-5, p_radius+5 do
                    if x^2+y^2 < decon_radius^2 then
                        table.insert(base_tiles,{name=decon_tile,position={x+offset.x,y+offset.y}})
                        if not CUSTOM_SPAWN then
                            local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                            for _,entity in pairs(entities) do if entity.name ~= 'character' then entity.destroy() end end
                        end
                    end
                end
            end
            surface.set_tiles(base_tiles)
            for _,position in pairs(tile_positions) do
                table.insert(tiles,{name=p_tile,position={position[1]+offset.x+global_offset.x,position[2]+offset.y+global_offset.y}})
            end
            surface.set_tiles(tiles)
            for _,entity in pairs(entitys) do
                local entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
                entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
            end
        global.spawn_generated = true
    end
end
event.add(defines.events.on_chunk_generated, function(event)
    if event.tick > 4 then 
        spawn_on_chunk_generated(event)
    end
end)