local Event = require 'utils.event'
require 's_utils'
require "frontier_silo"
require 'separate_spawns'
require 'config'
require 'alliance'
require 'junkyard'

g_surface = "wbtc"

local function on_start()
        InitSpawnGlobalsAndForces()
        if SILO_FIXED_POSITION then
            SetFixedSiloPosition(SILO_POSITION)
        else
            SetRandomSiloPosition(SILO_NUM_SPAWNS)
        end
        GenerateRocketSiloAreas(game.surfaces[g_surface])
end
Event.on_init(on_start)
----------------------------------------
-- Chunk Generation
----------------------------------------
Event.add(defines.events.on_chunk_generated, function(event)
            GenerateRocketSiloChunk(event)
            --SeparateSpawnsGenerateChunk(event)
            SetupAndClearSpawnAreas(event)
end)

Event.add(defines.events.on_player_created, function(event)
    if not game.forces["silo"] then game.create_force("silo") end
    game.forces["silo"].research_all_technologies()
end)


----------------------------------------
-- Shared vision chat
----------------------------------------
Event.add(defines.events.on_console_chat, function(event)
ShareChatBetweenForces(game.players[event.player_index], event.message)
end)
--Event.add(defines.events.on_console_chat, on_console_chat)

----------------------------------------
-- Shared vision, charts a small area around other players
----------------------------------------
Event.add(defines.events.on_tick, function(event)
        DelayedSiloCreationOnTick()
end)


----------------------------------------
-- On Research Finished
-- This is where you can permanently remove researched techs
----------------------------------------
Event.add(defines.events.on_research_finished, function(event)
        RemoveRecipe(event.research.force, "rocket-silo")
end)