local event = require 'utils.event'
local market_items = require "features.modules.map_market_items"
require 'features.modules.scramble'
--require 'features.modules.warp_system'
require 'features.modules.enhancedbiters'
--require 'features.modules.bp'
require 'features.modules.autodecon_when_depleted'
require 'features.modules.backpack_research'
require 'features.modules.biter_noms_you'
--require 'features.modules.biters_avoid_damage'
--require "features.modules.biters_yield_fish"
require 'features.modules.biters_double_damage'
--require 'features.modules.burden'
--require 'features.modules.comfylatron'
require 'features.modules.infinity_chest'
require 'features.modules.custom_death_messages'
require 'features.modules.explosive_biters'
require 'features.modules.fish_respawner'
require 'features.modules.spawn_area'
--require 'features.modules.dangerous_nights'
--require 'features.modules.satellite_score'
--require 'features.modules.show_health'
require 'features.modules.splice'
require 'features.modules.afk'

require 'map_gen.mps_0_16.oarc_utils'
require 'map_gen.mps_0_16.rso_control'
require 'map_gen.mps_0_16.frontier_silo'
require 'map_gen.mps_0_16.config'

require 'map_gen.mps_0_16.separate_spawns'
require 'map_gen.mps_0_16.separate_spawns_guis'
require 'map_gen.mps_0_16.regrowth_map'

local math_random = math.random

-- FOLLOWING CODE GIVES SAME MINIMUM INVENTORY TO ALL SCENARIOS:
--------------------------------------------------------------------------------
-- ALL EVENT HANLDERS ARE HERE IN ONE PLACE!
--------------------------------------------------------------------------------


local function secret_shop(pos)
    local secret_market_items = {
    {price = {{"raw-fish", math_random(250,450)}}, offer = {type = 'give-item', item = 'combat-shotgun'}},
    {price = {{"raw-fish", math_random(250,450)}}, offer = {type = 'give-item', item = 'flamethrower'}},
    {price = {{"raw-fish", math_random(75,125)}}, offer = {type = 'give-item', item = 'rocket-launcher'}},
    {price = {{"raw-fish", math_random(2,4)}}, offer = {type = 'give-item', item = 'piercing-rounds-magazine'}},
    {price = {{"raw-fish", math_random(8,16)}}, offer = {type = 'give-item', item = 'uranium-rounds-magazine'}},  
    {price = {{"raw-fish", math_random(8,16)}}, offer = {type = 'give-item', item = 'piercing-shotgun-shell'}},
    {price = {{"raw-fish", math_random(6,12)}}, offer = {type = 'give-item', item = 'flamethrower-ammo'}},
    {price = {{"raw-fish", math_random(8,16)}}, offer = {type = 'give-item', item = 'rocket'}},
    {price = {{"raw-fish", math_random(10,20)}}, offer = {type = 'give-item', item = 'explosive-rocket'}},        
    {price = {{"raw-fish", math_random(15,30)}}, offer = {type = 'give-item', item = 'explosive-cannon-shell'}},
    {price = {{"raw-fish", math_random(25,35)}}, offer = {type = 'give-item', item = 'explosive-uranium-cannon-shell'}},   
    {price = {{"raw-fish", math_random(20,40)}}, offer = {type = 'give-item', item = 'cluster-grenade'}}, 
    {price = {{"raw-fish", math_random(1,3)}}, offer = {type = 'give-item', item = 'land-mine'}},   
    {price = {{"raw-fish", math_random(250,500)}}, offer = {type = 'give-item', item = 'modular-armor'}},
    {price = {{"raw-fish", math_random(1500,3000)}}, offer = {type = 'give-item', item = 'power-armor'}},
    {price = {{"raw-fish", math_random(15000,20000)}}, offer = {type = 'give-item', item = 'power-armor-mk2'}},
    {price = {{"raw-fish", math_random(4000,7000)}}, offer = {type = 'give-item', item = 'fusion-reactor-equipment'}},
    {price = {{"raw-fish", math_random(50,100)}}, offer = {type = 'give-item', item = 'battery-equipment'}},
    {price = {{"raw-fish", math_random(700,1100)}}, offer = {type = 'give-item', item = 'battery-mk2-equipment'}},
    {price = {{"raw-fish", math_random(400,700)}}, offer = {type = 'give-item', item = 'belt-immunity-equipment'}},
    {price = {{"raw-fish", math_random(12000,16000)}}, offer = {type = 'give-item', item = 'night-vision-equipment'}},
    {price = {{"raw-fish", math_random(300,500)}}, offer = {type = 'give-item', item = 'exoskeleton-equipment'}},
    {price = {{"raw-fish", math_random(350,500)}}, offer = {type = 'give-item', item = 'personal-roboport-equipment'}},
    {price = {{"raw-fish", math_random(25,50)}}, offer = {type = 'give-item', item = 'construction-robot'}},
    {price = {{"raw-fish", math_random(250,450)}}, offer = {type = 'give-item', item = 'energy-shield-equipment'}},
    {price = {{"raw-fish", math_random(350,550)}}, offer = {type = 'give-item', item = 'personal-laser-defense-equipment'}},    
    {price = {{"raw-fish", math_random(125,250)}}, offer = {type = 'give-item', item = 'railgun'}},
    {price = {{"raw-fish", math_random(2,4)}}, offer = {type = 'give-item', item = 'railgun-dart'}},
    {price = {{"raw-fish", math_random(100,175)}}, offer = {type = 'give-item', item = 'loader'}},
    {price = {{"raw-fish", math_random(200,350)}}, offer = {type = 'give-item', item = 'fast-loader'}},
    {price = {{"raw-fish", math_random(400,600)}}, offer = {type = 'give-item', item = 'express-loader'}}
    }
    secret_market_items = shuffle(secret_market_items)

    local surface = game.surfaces[GAME_SURFACE_NAME]
    local market = surface.create_entity {name = "market", position = pos}
    market.destructible = false

    if enable_fishbank_terminal then
        market.add_market_item({price = {}, offer = {type = 'nothing', effect_description = 'Deposit Fish'}})
        market.add_market_item({price = {}, offer = {type = 'nothing', effect_description = 'Withdraw Fish - 1% Bank Fee'}})
        market.add_market_item({price = {}, offer = {type = 'nothing', effect_description = 'Show Account Balance'}})   
    end

    for i = 1, math_random(8,12), 1 do
        market.add_market_item(secret_market_items[i])
    end
end




----------------------------------------
-- On Init - only runs once the first 
--   time the game starts
----------------------------------------
local function on_start()

    -- CreateLobbySurface() -- Currently unused, but have plans for future.

    -- Configures the map settings for enemies
    -- This controls evolution growth factors and enemy expansion settings.
    --ConfigureAlienStartingParams()

    -- Here I create the game surface. I do this so that I don't have to worry
    -- about the game menu settings and I can now generate a map from the command
    -- line more easily!

    if ENABLE_SCRAMBLE then
    divOresity_init()
    end

    if ENABLE_RSO then
        CreateGameSurface(RSO_MODE)
    else
        CreateGameSurface(VANILLA_MODE)
    end

    if ENABLE_SEPARATE_SPAWNS then
        InitSpawnGlobalsAndForces()
    end

    if SILO_FIXED_POSITION then
        SetFixedSiloPosition(SILO_POSITION)
    else
        SetRandomSiloPosition(SILO_NUM_SPAWNS)
    end

    if FRONTIER_ROCKET_SILO_MODE then
        GenerateRocketSiloAreas(game.surfaces[GAME_SURFACE_NAME])
    end

    OarcRegrowthInit()
end

event.on_init(on_start)

----------------------------------------
-- Chunk Generation
----------------------------------------
event.add(defines.events.on_chunk_generated, function(event)

    if ENABLE_REGROWTH then
        OarcRegrowthChunkGenerate(event.area.left_top)
    end

    if ENABLE_RSO then
        RSO_ChunkGenerated(event)
    end
    if ENABLE_SCRAMBLE then
    diversify(event)
    end

    if FRONTIER_ROCKET_SILO_MODE then
        GenerateRocketSiloChunk(event)
    end

    if ENABLE_SEPARATE_SPAWNS and not USE_VANILLA_STARTING_SPAWN then
        SeparateSpawnsGenerateChunk(event)
    end

        --CreateHoldingPen(event.surface, event.area, 12, false)
end)


----------------------------------------
-- Gui Click
----------------------------------------
event.add(defines.events.on_gui_click, function(event)
    if ENABLE_PLAYER_LIST then
        PlayerListGuiClick(event)
    end

    if ENABLE_SEPARATE_SPAWNS then
        WelcomeTextGuiClick(event)
        SpawnOptsGuiClick(event)
        SpawnCtrlGuiClick(event)
        SharedSpwnOptsGuiClick(event)
        BuddySpawnOptsGuiClick(event)
        BuddySpawnWaitMenuClick(event)
        BuddySpawnRequestMenuClick(event)
        SharedSpawnJoinWaitMenuClick(event)
    end
end)
    


event.add(defines.events.on_gui_checked_state_changed, function(event)

    if ENABLE_SEPARATE_SPAWNS then
        SpawnOptsRadioSelect(event)
        SpawnCtrlGuiOptionsSelect(event)
    end
end)


event.add(defines.events.on_player_created, function(event)
 -- Move the player to the game surface immediately.
    -- May change this to Lobby in the future.
    game.players[event.player_index].teleport(game.forces[MAIN_FORCE].get_spawn_position(GAME_SURFACE_NAME), GAME_SURFACE_NAME)

    if ENABLE_LONGREACH then
        GivePlayerLongReach(game.players[event.player_index])
    end

    if not ENABLE_SEPARATE_SPAWNS then
        PlayerSpawnItems(event)
    else
        SeparateSpawnsPlayerCreated(event)
    end
end)

event.add(defines.events.on_player_respawned, function(event)
    if ENABLE_SEPARATE_SPAWNS then
        SeparateSpawnsPlayerRespawned(event)        
    end
   
    PlayerRespawnItems(event)

    if ENABLE_LONGREACH then
        GivePlayerLongReach(game.players[event.player_index])
    end
end)


event.add(defines.events.on_pre_player_died, function(event)
    if ENABLE_GRAVESTONE_ON_DEATH then
        DropGravestoneChests(game.players[event.player_index])
    end
end)

event.add(defines.events.on_player_left_game, function(event)
    if ENABLE_SEPARATE_SPAWNS then
        FindUnusedSpawns(event)
    end
end)

event.add(defines.events.on_built_entity, function(event)
    if ENABLE_AUTOFILL then
        Autofill(event)
    end

    if ENABLE_REGROWTH then
        OarcRegrowthOffLimitsChunk(event.created_entity.position)
    end

    if ENABLE_ANTI_GRIEFING then
        SetItemBlueprintTimeToLive(event)
    end
end)

----------------------------------------
-- Shared vision, charts a small area around other players
----------------------------------------
event.add(defines.events.on_tick, function(event)

    if ENABLE_REGROWTH then
        OarcRegrowthOnTick()
    end

    if ENABLE_ABANDONED_BASE_REMOVAL then
        OarcRegrowthForceRemovalOnTick()
    end

    if ENABLE_SEPARATE_SPAWNS then
        DelayedSpawnOnTick()
    end

    if FRONTIER_ROCKET_SILO_MODE then
        DelayedSiloCreationOnTick()
    end

    if ENABLE_MARKET then
        if game.tick == 150 then
            local surface = game.surfaces[GAME_SURFACE_NAME]
            local p = game.surfaces[GAME_SURFACE_NAME].find_non_colliding_position("market",{-10,-10},60,2)

            global.market = surface.create_entity {name = "market", position = p}

            rendering.draw_text{
              text = "Market",
              surface = surface,
              target = global.market,
              target_offset = {0, 2},
              color = { r=0.98, g=0.66, b=0.22},
              alignment = "center"
            }
    
            global.market.destructible = false
            
            for _, item in pairs(market_items.spawn) do
                global.market.add_market_item(item)
            end             
        end     
    end    

end)


event.add(defines.events.on_sector_scanned, function(event)
    if ENABLE_REGROWTH then
        OarcRegrowthSectorScan(event)
    end
end)

event.add(defines.events.on_player_mined_entity, function(event)
    if math_random(1, 2) == 1 then 
      event.entity.surface.spill_item_stack(game.players[event.player_index].position,{name = "raw-fish", count = math_random(1,2)},true)
    end
end)

----------------------------------------
-- Refreshes regrowth timers around an active timer
-- Refresh areas where stuff is built, and mark any chunks with player
-- built stuff as permanent.
----------------------------------------
if ENABLE_REGROWTH then
    event.add(defines.events.on_robot_built_entity, function(event)
        OarcRegrowthOffLimitsChunk(event.created_entity.position)
    end)
    
    event.add(defines.events.on_player_mined_entity, function(event)
        OarcRegrowthCheckChunkEmpty(event)
    end)

    event.add(defines.events.on_robot_mined_entity, function(event)
        OarcRegrowthCheckChunkEmpty(event)
    end)
end



----------------------------------------
-- Shared chat, so you don't have to type /s
----------------------------------------
event.add(defines.events.on_console_chat, function(event)
    if (ENABLE_SHARED_TEAM_CHAT) then
        if (event.player_index ~= nil) then
            ShareChatBetweenForces(game.players[event.player_index], event.message)
        end
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



--[[setmetatable(_G, {
    __newindex = function(_, n, v)
        log("Desync warning: attempt to write to undeclared var " .. n)
        -- game.print("Attempt to write to undeclared var " .. n)
        global[n] = v;
    end,
    __index = function(_, n)
        return global[n];
    end
})

--]]
