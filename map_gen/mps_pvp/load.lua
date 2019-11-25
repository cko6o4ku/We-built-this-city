require 'alliance'
require 'msp_intro'
require 's_utils' 
require 'maps.modules.rso.rso_control'
require 'separate_spawns'
require 'config'
local event = require 'utils.event'

local function on_start()

    if not ENABLE_RSO then
    CreateGameSurface(RSO_MODE)
    end

    if ENABLE_SEPARATE_SPAWNS then
        InitSpawnGlobalsAndForces()
    end
    if FRONTIER_ROCKET_SILO_MODE then
        if SILO_FIXED_POSITION then
            SetFixedSiloPosition(SILO_POSITION)
        else
            SetRandomSiloPosition(SILO_NUM_SPAWNS)
        end
    end

    if FRONTIER_ROCKET_SILO_MODE then
        GenerateRocketSiloAreas(game.surfaces[g_surface])
    end


end
event.on_init(on_start)

if CUSTOM_SPAWN then
event.add(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]       
    if not global.surface_init_done then      
        map_gen_settings = {}
        map_gen_settings.water = "none"
        map_gen_settings.cliff_settings = {cliff_elevation_interval = 0, cliff_elevation_0 = 1000}       
        map_gen_settings.autoplace_controls = {
            ["coal"] = {frequency = "normal", size = "none", richness = "normal"},
            ["stone"] = {frequency = "normal", size = "none", richness = "normal"},
            ["copper-ore"] = {frequency = "normal", size = "none", richness = "normal"},
            ["iron-ore"] = {frequency = "normal", size = "none", richness = "normal"},
            ["crude-oil"] = {frequency = "normal", size = "none", richness = "good"},
            ["trees"] = {frequency = "normal", size = "none", richness = "normal"},
            ["enemy-base"] = {frequency = "normal", size = "none", richness = "good"}           
        }
        game.create_surface(g_surface, map_gen_settings)
            
        local surface = game.surfaces[g_surface] 
        global.surface_init_done = true
    end       
    local surface = game.surfaces[g_surface]
    if player.online_time < 5 and surface.is_chunk_generated({0,0}) then 
        player.teleport(surface.find_non_colliding_position("player", {0,0}, 2, 1), g_surface)
    else
        if player.online_time < 5 then
            player.teleport({0,0}, g_surface)
        end
    end 

end)
end

----------------------------------------
-- Chunk Generation
----------------------------------------
event.add(defines.events.on_chunk_generated, function(event)
    replace_spawn_water(game.surfaces[g_surface])

    if event.tick > 4 then    
        local pos = {x=-0,y=0} 
        local radius = 50
        local area = {left_top = {pos.x-radius, pos.y-radius}, right_bottom = {pos.x+radius, pos.y+radius}} 
        --for _, e in pairs(game.surfaces[g_surface].find_entities_filtered{area=area, type="tree"}) do   
            --e.destroy() 
        --end
        for _, f in pairs(game.surfaces[g_surface].find_entities_filtered{area=area, force="enemy"}) do   
            f.destroy() 
        end
        
        --rivers_on_chunk(event)
        
        if ENABLE_RSO then
        RSO_ChunkGenerated(event)
        end
        
        if FRONTIER_ROCKET_SILO_MODE then
            GenerateRocketSiloChunk(event)
        end
        
        if ENABLE_SEPARATE_SPAWNS and not USE_VANILLA_STARTING_SPAWN then
            SeparateSpawnsGenerateChunk(event)
        end
        
        --CreateHoldingPen(event.surface, event.area, 6, false)
        
        if CIRCLE_RESOURCE then
        gen_on_chunk_generated(event)
        end

        if ENABLE_SPAWN then
            spawn_on_chunk_generated(event)
        end

    end
end)

event.add(defines.events.on_player_created, function(event)
    if FRONTIER_ROCKET_SILO_MODE then
    if not game.forces["silo"] then game.create_force("silo") end
    end

    PlayerSpawnItems(event)

end)

event.add(defines.events.on_player_respawned, function(event)
    if ENABLE_SEPARATE_SPAWNS then
        SeparateSpawnsPlayerRespawned(event)        
    end

    PlayerRespawnItems(event)

end)


event.add(defines.events.on_built_entity, function(event)
    if ENABLE_AUTOFILL then
        Autofill(event)
    end 

    spawn_protected(event)


    if ENABLE_ANTI_GRIEFING then
        SetItemBlueprintTimeToLive(event)
    end
end)

----------------------------------------
-- Shared vision, charts a small area around other players
----------------------------------------
event.add(defines.events.on_tick, function(event)

    if ENABLE_SEPARATE_SPAWNS then
        DelayedSpawnOnTick()
    end

    if FRONTIER_ROCKET_SILO_MODE then
        DelayedSiloCreationOnTick()
    end

end)


----------------------------------------
-- On Research Finished
-- This is where you can permanently remove researched techs
----------------------------------------
event.add(defines.events.on_research_finished, function(event)
    if FRONTIER_ROCKET_SILO_MODE then
        RemoveRecipe(event.research.force, "rocket-silo")
    end
end)


if DESYNC_DEBUG then 
setmetatable(_G, {
    __newindex = function(_, n, v)
        log("Desync warning: attempt to write to undeclared var " .. n)
        --print("Desync warning: var.." .. n)
        global[n] = v;
    end,
    __index = function(_, n)
        return global[n];
    end
})
end


