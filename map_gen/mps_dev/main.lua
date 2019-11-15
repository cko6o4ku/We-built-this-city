local event = require 'utils.event'
local market_items = require "features.modules.map_market_items"
local Tabs = require 'features.gui.main'
local RPG = require 'features.modules.rpg'
local fish = require 'features.modules.launch_fish_to_win'
local Surface = require 'utils.surface'.get_surface_name()
require 'features.modules.scramble'
require 'features.modules.warp_system'
require 'features.modules.enhancedbiters'
--require 'features.modules.bp'
require 'features.modules.autodecon_when_depleted'
require 'features.modules.spawners_contain_biters'
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
require 'features.modules.show_health'
require 'features.modules.splice'
require 'features.modules.afk'

require 'map_gen.mps_dev.lib.oarc_utils'

-- Other soft-mod type features.
require 'map_gen.mps_dev.lib.frontier_silo'
require 'map_gen.mps_dev.lib.tag'
require 'map_gen.mps_dev.lib.player_list'
require 'map_gen.mps_dev.lib.rocket_launch'
require 'map_gen.mps_dev.lib.admin_commands'
require 'map_gen.mps_dev.lib.regrowth_map'

-- Main Configuration File
require 'map_gen.mps_dev.config'

-- Save all config settings to global table.
require 'map_gen.mps_dev.lib.oarc_global_cfg'

-- Scenario Specific Includes
require 'map_gen.mps_dev.lib.separate_spawns'
require 'map_gen.mps_dev.lib.separate_spawns_guis'

-- Create a new surface so we can modify map settings at the start.
GAME_SURFACE_NAME = Surface
local math_random = math.random


-- I'm reverting my decision to turn the regrowth thing into a mod.
remote.add_interface ("oarc_regrowth",
            {area_offlimits_chunkpos = MarkAreaSafeGivenChunkPos,
            area_offlimits_tilepos = MarkAreaSafeGivenTilePos,
            area_removal_tilepos = MarkAreaForRemoval,
            trigger_immediate_cleanup = TriggerCleanup,
            add_surface = RegrowthAddSurface})

commands.add_command ("trigger-map-cleanup",
    "Force immediate removal of all expired chunks (unused chunk removal mod)",
    ForceRemoveChunksCmd)

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

    ----------------------------
    --- Tabs options here!
    ----------------------------
    Tabs.set_tab_on_init("Spawn Controls", false)
    Tabs.set_tab_on_init("Rockets", false)

    if ENABLE_SCRAMBLE then
    divOresity_init()
    end

    -- FIRST
    InitOarcConfig()

    -- Regrowth (always init so we can enable during play.)
    RegrowthInit()

    -- Create new game surface
    CreateGameSurface()

    -- MUST be before other stuff, but after surface creation.
    InitSpawnGlobalsAndForces()

    -- Frontier Silo Area Generation
    if (global.ocfg.frontier_rocket_silo) then
        SpawnSilosAndGenerateSiloAreas()
    end

    local p = game.permissions.create_group("spectator")
    for action_name, _ in pairs(defines.input_action) do
        p.set_allows_action(defines.input_action[action_name], false)
    end

    local defs = {
        defines.input_action.write_to_console,
        defines.input_action.gui_click,
        defines.input_action.gui_selection_state_changed,
        defines.input_action.gui_checked_state_changed  ,
        defines.input_action.gui_elem_changed,
        defines.input_action.gui_text_changed,
        defines.input_action.gui_value_changed,
        defines.input_action.open_kills_gui,
        defines.input_action.open_character_gui,
        defines.input_action.edit_permission_group,
        defines.input_action.toggle_show_entity_info,
        defines.input_action.rotate_entity,
    }
    for k, v in pairs(defs) do p.set_allows_action(v, true) end

    -- Everyone do the shuffle. Helps avoid always starting at the same location.
    global.vanillaSpawns = FYShuffle(global.vanillaSpawns)
    --log ("Vanilla spawns:")
    --log(serpent.block(global.vanillaSpawns))
end
event.on_init(on_start)


----------------------------------------
-- Rocket launch event
-- Used for end game win conditions / unlocking late game stuff
----------------------------------------
event.add(defines.events.on_rocket_launched, function(event)
    if global.ocfg.frontier_rocket_silo then
        RocketLaunchEvent(event)
    end
end)


----------------------------------------
-- Chunk Generation
----------------------------------------
event.add(defines.events.on_chunk_generated, function(event)
    if event.surface.index == 1 then return end
    local surface = event.surface
    local pos = event.position
    if ENABLE_SCRAMBLE then
    diversify(event)
    end

    if global.ocfg.enable_regrowth then
        RegrowthChunkGenerate(event)
    end
    if global.ocfg.enable_undecorator then
        UndecorateOnChunkGenerate(event)
    end

    if global.ocfg.frontier_rocket_silo then
        GenerateRocketSiloChunk(event)
    end

    SeparateSpawnsGenerateChunk(event)

    --CreateHoldingPen(event.surface, event.area, 16, 32)
end)


----------------------------------------
-- Gui Click
----------------------------------------
event.add(defines.events.on_gui_click, function(event)

    -- Don't interfere with other mod related stuff.

    WelcomeTextGuiClick(event)
    SpawnOptsGuiClick(event)
    SpawnCtrlGuiClick(event)
    SharedSpwnOptsGuiClick(event)
    BuddySpawnOptsGuiClick(event)
    BuddySpawnWaitMenuClick(event)
    BuddySpawnRequestMenuClick(event)
    SharedSpawnJoinWaitMenuClick(event)
end)

event.add(defines.events.on_gui_checked_state_changed, function (event)
    SpawnOptsRadioSelect(event)
    SpawnCtrlGuiOptionsSelect(event)
end)

----------------------------------------
-- Player Events
----------------------------------------
event.add(defines.events.on_player_joined_game, function(event)
    PlayerJoinedMessages(event)
end)

event.add(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]

    -- Move the player to the game surface immediately.
    player.teleport({x=0,y=0}, GAME_SURFACE_NAME)

    if global.ocfg.enable_long_reach then
        GivePlayerLongReach(player)
    end

    if player.online_time == 0 then
        game.permissions.get_group("spectator").add_player(player)
    end

    SeparateSpawnsPlayerCreated(event.player_index)
end)

event.add(defines.events.on_player_respawned, function(event)
    SeparateSpawnsPlayerRespawned(event)

    PlayerRespawnItems(event)

    if global.ocfg.enable_long_reach then
        GivePlayerLongReach(game.players[event.player_index])
    end
end)

event.add(defines.events.on_player_left_game, function(event)
    FindUnusedSpawns(game.players[event.player_index], true)
end)

----------------------------------------
-- On BUILD entity. Don't forget on_robot_built_entity too!
----------------------------------------
event.add(defines.events.on_built_entity, function(event)
    if global.ocfg.enable_autofill then
        Autofill(event)
    end

    if global.ocfg.enable_regrowth then
        local s_index = event.created_entity.surface.index
        if (global.rg[s_index] == nil) then return end

        remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    event.created_entity.position,
                    2)
    end

    if global.ocfg.frontier_rocket_silo then
        BuildSiloAttempt(event)
    end

end)


----------------------------------------
-- On script_raised_built. This should help catch mods that
-- place items that don't count as player_built and robot_built.
-- Specifically FARL.
----------------------------------------
event.add(defines.events.script_raised_built, function(event)
    if global.ocfg.enable_regrowth then
        local s_index = event.entity.surface.index
        if (global.rg[s_index] == nil) then return end

        remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    event.entity.position,
                    2)
    end
end)


----------------------------------------
-- On tick events. Stuff that needs to happen at regular intervals.
-- Delayed events, delayed spawns, ...
----------------------------------------
event.add(defines.events.on_tick, function(event)
    if global.ocfg.enable_regrowth then
        RegrowthOnTick()
        RegrowthForceRemovalOnTick()
    end

    DelayedSpawnOnTick()

    if global.ocfg.frontier_rocket_silo then
        DelayedSiloCreationOnTick(game.surfaces[GAME_SURFACE_NAME])
    end

    if ENABLE_MARKET then
        if game.tick == 150 then
            local surface = game.surfaces[GAME_SURFACE_NAME]
            local p = game.surfaces[GAME_SURFACE_NAME].find_non_colliding_position ("market",{-10,-10},60,2)

            global.market = surface.create_entity {name = "market", position = p, force = "player"}

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


event.add(defines.events.on_sector_scanned, function (event)
    if global.ocfg.enable_regrowth then
        RegrowthSectorScan(event)
    end
end)

event.add(defines.events.on_player_mined_entity, function(event)
    local e = event.entity
    if e and e.valid and math_random(1, 10) == 1 then
      e.surface.spill_item_stack(game.players[event.player_index].position,{name = "raw-fish", count = math_random(1,2)},true)
    end
end)
-- event.add(defines.events.on_sector_scanned, function (event)

-- end)

----------------------------------------
--
----------------------------------------
event.add(defines.events.on_robot_built_entity, function (event)
    if global.ocfg.enable_regrowth then
        local s_index = event.created_entity.surface.index
        if (global.rg[s_index] == nil) then return end

        remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    event.created_entity.position,
                    2)
    end
    if global.ocfg.frontier_rocket_silo then
        BuildSiloAttempt(event)
    end
end)

event.add(defines.events.on_player_built_tile, function (event)
    if global.ocfg.enable_regrowth then
        local s_index = event.surface_index
        if (global.rg[s_index] == nil) then return end

        for k,v in pairs(event.tiles) do
            remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    v.position,
                    2)
        end
    end
end)




----------------------------------------
-- Shared chat, so you don't have to type /s
-- But you do lose your player colors across forces.
----------------------------------------
event.add(defines.events.on_console_chat, function(event)
    if (global.ocfg.enable_shared_chat) then
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
    local research = event.research
    local force_name = research.force.name
    if research.name == "rocket-silo" then
        game.forces[force_name].print("Note! Rocket-silos can only be built on designated areas! You can find these on the mini-map.", { r=0, g=255, b=171})
        game.forces[force_name].play_sound{path="utility/new_objective", volume_modifier=0.75}
    end

    -- Never allows players to build rocket-silos in "frontier" mode.
    if global.ocfg.frontier_rocket_silo and not global.ocfg.frontier_allow_build then
        RemoveRecipe(event.research.force, "rocket-silo")
    end

    if global.ocfg.lock_goodies_rocket_launch and
        (not global.satellite_sent or not global.satellite_sent[event.research.force.name]) then
        RemoveRecipe(event.research.force, "productivity-module-3")
        RemoveRecipe(event.research.force, "speed-module-3")
    end

    if global.ocfg.enable_loaders then
        EnableLoaders(event)
    end
end)

----------------------------------------
-- On Entity Spawned and On Biter Base Built
-- This is where I modify biter spawning based on location and other factors.
----------------------------------------
event.add(defines.events.on_entity_spawned, function(event)
    if (global.ocfg.modified_enemy_spawning) then
        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)
event.add(defines.events.on_biter_base_built, function(event)
    if (global.ocfg.modified_enemy_spawning) then
        ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)

----------------------------------------
-- On Corpse Timed Out
-- Save player's stuff so they don't lose it if they can't get to the corpse fast enough.
----------------------------------------
event.add(defines.events.on_character_corpse_expired, function(event)
    DropGravestoneChestFromCorpse(event.corpse)
end)

--[[setmetatable(_G, {
    __newindex = function(_, n, v)
        log 'Desync warning: attempt to write to undeclared var " .. n)
        -- game.print 'Attempt to write to undeclared var " .. n)
        global[n] = v;
    end,
    __index = function(_, n)
        return global[n];
    end
})

--]]