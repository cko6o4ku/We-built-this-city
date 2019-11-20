local Event = require 'utils.event'
local market_items = require "features.modules.map_market_items"
local Tabs = require 'features.gui.main'
local RPG = require 'features.modules.rpg'
local fish = require 'features.modules.launch_fish_to_win'
require 'features.modules.ores_are_mixed'
--local Map = require 'features.modules.map_info'
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
--require 'features.modules.fish_respawner' --- VERY HEAVY
require 'features.modules.spawn_area'
--require 'features.modules.dangerous_nights'
--require 'features.modules.satellite_score'
require 'features.modules.show_health'
require 'features.modules.splice'
require 'features.modules.afk'

local Utils = require 'map_gen.mps_0_17.lib.oarc_utils'

-- Other soft-mod type features.
local Silo = require 'map_gen.mps_0_17.lib.frontier_silo'
local R_launch = require 'map_gen.mps_0_17.lib.rocket_launch'
local Regrowth = require 'map_gen.mps_0_17.lib.regrowth_map'

-- Main Configuration File
local Config = require 'map_gen.mps_0_17.config'
local Surface = require 'utils.surface'.get_surface_name()

-- Scenario Specific Includes
local SS = require 'map_gen.mps_0_17.lib.separate_spawns'

local math_random = math.random


-- I'm reverting my decision to turn the regrowth thing into a mod.
remote.add_interface ("oarc_regrowth",
            {area_offlimits_chunkpos = Regrowth.MarkAreaSafeGivenChunkPos,
            area_offlimits_tilepos = Regrowth.MarkAreaSafeGivenTilePos,
            area_removal_tilepos = Regrowth.MarkAreaForRemoval,
            trigger_immediate_cleanup = Regrowth.TriggerCleanup,
            add_surface = Regrowth.RegrowthAddSurface})

commands.add_command ("trigger-map-cleanup",
    "Force immediate removal of all expired chunks (unused chunk removal mod)",
    Regrowth.ForceRemoveChunksCmd)

----------------------------------------
-- On Init - only runs once the first
--   time the game starts
----------------------------------------
local function on_start()

--[[
    local T = Map.Pop_info()
        T.main_caption = "Multiplayer Spawn"
        T.sub_caption =  "    launch the rocket!    "
        T.main_caption_color = {r = 150, g = 150, b = 0}
        T.sub_caption_color = {r = 0, g = 150, b = 0}
]]--

    -- Create new game surface
    Utils.CreateGameSurface()

    -- MUST be before other stuff, but after surface creation.
    SS.InitSpawnGlobalsAndForces()

    -- Frontier Silo Area Generation
    if (global.frontier_rocket_silo_mode) then
        Silo.SpawnSilosAndGenerateSiloAreas()
    end

    local p = game.permissions.create_group("spectator")
    for action_name, _ in pairs(defines.input_action) do
        p.set_allows_action(defines.input_action[action_name], false)
    end

    local defs = {
        defines.input_action.write_to_console,
        defines.input_action.gui_click,
        defines.input_action.gui_selection_state_changed,
        defines.input_action.gui_checked_state_changed,
        defines.input_action.gui_selected_tab_changed,
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
    global.vanillaSpawns = Utils.FYShuffle(global.vanillaSpawns)
    --log ("Vanilla spawns:")
    --log(serpent.block(global.vanillaSpawns))
end
Event.on_init(on_start)


----------------------------------------
-- Rocket launch event
-- Used for end game win conditions / unlocking late game stuff
----------------------------------------
Event.add(defines.events.on_rocket_launched, function(event)
    if global.frontier_rocket_silo_mode then
        R_launch.RocketLaunchEvent(event)
    end
end)


----------------------------------------
-- Chunk Generation
----------------------------------------
Event.add(defines.events.on_chunk_generated, function(event)
    if event.surface.index == 1 then return end

    if global.enable_regrowth then
        Regrowth.RegrowthChunkGenerate(event)
    end
    if global.enable_undecorator then
        Utils.UndecorateOnChunkGenerate(event)
    end

    Silo.GenerateRocketSiloChunk(event)

    SS.SeparateSpawnsGenerateChunk(event)

    --CreateHoldingPen(event.surface, event.area, 16, 32)
end)


----------------------------------------
-- Gui Click
----------------------------------------
Event.add(defines.events.on_gui_click, function(event)

    -- Don't interfere with other mod related stuff.

    SS.WelcomeTextGuiClick(event)
    SS.SpawnOptsGuiClick(event)
    SS.SpawnCtrlGuiClick(event)
    SS.SharedSpwnOptsGuiClick(event)
    SS.BuddySpawnOptsGuiClick(event)
    SS.BuddySpawnWaitMenuClick(event)
    SS.BuddySpawnRequestMenuClick(event)
    SS.SharedSpawnJoinWaitMenuClick(event)
end)

Event.add(defines.events.on_gui_checked_state_changed, function (event)
    SS.SpawnOptsRadioSelect(event)
    SS.SpawnCtrlGuiOptionsSelect(event)
end)

----------------------------------------
-- Player Events
----------------------------------------
Event.add(defines.events.on_player_joined_game, function(event)
    Utils.PlayerJoinedMessages(event)
end)

Event.add(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]

    -- Move the player to the game surface immediately.
    local pos = game.surfaces[Surface].find_non_colliding_position("character", {x=0,y=0}, 3, 0,5)
    player.teleport(pos, Surface)

    if global.enable_longreach then
        Utils.GivePlayerLongReach(player)
    end

    if player.online_time == 0 then
        game.permissions.get_group("spectator").add_player(player)
    end

    SS.SeparateSpawnsPlayerCreated(event.player_index)
end)

Event.add(defines.events.on_player_respawned, function(event)
    SS.SeparateSpawnsPlayerRespawned(event)

    Utils.PlayerRespawnItems(event)

    if global.enable_longreach then
        Utils.GivePlayerLongReach(game.players[event.player_index])
    end
end)

Event.add(defines.events.on_player_left_game, function(event)
    SS.FindUnusedSpawns(game.players[event.player_index], true)
end)

----------------------------------------
-- On BUILD entity. Don't forget on_robot_built_entity too!
----------------------------------------
Event.add(defines.events.on_built_entity, function(event)
    local rg = Regrowth.get_table()
    if global.enable_autofill then
        Utils.Autofill(event)
    end

    if global.enable_regrowth then
        local s_index = event.created_entity.surface.index
        if (rg[s_index] == nil) then return end

        remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    event.created_entity.position,
                    2)
    end

    if global.frontier_rocket_silo_mode then
        Silo.BuildSiloAttempt(event)
    end

end)


----------------------------------------
-- On script_raised_built. This should help catch mods that
-- place items that don't count as player_built and robot_built.
-- Specifically FARL.
----------------------------------------
Event.add(defines.events.script_raised_built, function(event)
    local rg = Regrowth.get_table()
    if global.enable_regrowth then
        local s_index = event.entity.surface.index
        if (rg[s_index] == nil) then return end

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
Event.add(defines.events.on_tick, function()
    if global.enable_regrowth then
        Regrowth.RegrowthOnTick()
        Regrowth.RegrowthForceRemovalOnTick()
    end

    SS.DelayedSpawnOnTick()

    if global.frontier_rocket_silo_mode then
        Silo.DelayedSiloCreationOnTick(game.surfaces[Surface])
    end

    if global.enable_market then
        if game.tick == 150 then
            local surface = game.surfaces[Surface]
            local p = game.surfaces[Surface].find_non_colliding_position ("market",{-10,-10},60,2)

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


Event.add(defines.events.on_sector_scanned, function (event)
    if global.enable_regrowth then
        Regrowth.RegrowthSectorScan(event)
    end
end)

Event.add(defines.events.on_player_mined_entity, function(event)
    local e = event.entity
    if e.type ~= "tree" then return end
    if e and e.valid and math_random(1, 10) == 1 then
      e.surface.spill_item_stack(game.players[event.player_index].position,{name = "raw-fish", count = math_random(1,2)},true)
    end
end)
-- Event.add(defines.events.on_sector_scanned, function (event)

-- end)

----------------------------------------
--
----------------------------------------
Event.add(defines.events.on_robot_built_entity, function (event)
    local rg = Regrowth.get_table()
    if global.enable_regrowth then
        local s_index = event.created_entity.surface.index
        if (rg[s_index] == nil) then return end

        remote.call ("oarc_regrowth",
                    "area_offlimits_tilepos",
                    s_index,
                    event.created_entity.position,
                    2)
    end
    if global.frontier_rocket_silo_mode then
        Silo.BuildSiloAttempt(event)
    end
end)

Event.add(defines.events.on_player_built_tile, function (event)
    local rg = Regrowth.get_table()
    if global.enable_regrowth then
        local s_index = event.surface_index
        if (rg[s_index] == nil) then return end

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
Event.add(defines.events.on_console_chat, function(event)
    if (global.team_chat) then
        if (event.player_index ~= nil) then
            Utils.ShareChatBetweenForces(game.players[event.player_index], event.message)
        end
    end
end)

----------------------------------------
-- On Research Finished
-- This is where you can permanently remove researched techs
----------------------------------------
Event.add(defines.events.on_research_finished, function(event)
    local research = event.research
    local force_name = research.force.name
    if research.name == "rocket-silo" then
        game.forces[force_name].print("Note! Rocket-silos can only be built on designated areas! You can find these on the mini-map.", { r=0, g=255, b=171})
        game.forces[force_name].play_sound{path="utility/new_objective", volume_modifier=0.75}
    end

    -- Never allows players to build rocket-silos in "frontier" mode.
    if global.frontier_rocket_silo_mode and not global.enable_silo_player_build then
        Utils.RemoveRecipe(event.research.force, "rocket-silo")
    end

    if global.enable_loaders then
        Utils.EnableLoaders(event)
    end
end)

----------------------------------------
-- On Entity Spawned and On Biter Base Built
-- This is where I modify biter spawning based on location and other factors.
----------------------------------------
Event.add(defines.events.on_entity_spawned, function(event)
    if (global.modded_enemy) then
        SS.ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)
Event.add(defines.events.on_biter_base_built, function(event)
    if (global.modded_enemy) then
        SS.ModifyEnemySpawnsNearPlayerStartingAreas(event)
    end
end)

----------------------------------------
-- On Corpse Timed Out
-- Save player's stuff so they don't lose it if they can't get to the corpse fast enough.
----------------------------------------
Event.add(defines.events.on_character_corpse_expired, function(event)
    Utils.DropGravestoneChestFromCorpse(event.corpse)
end)

--[[
setmetatable(_G, {
    __newindex = function(_, n, v)
        log ("Desync warning: attempt to write to undeclared var " .. n)
        --game.print ("Attempt to write to undeclared var " .. n)
        global[n] = v;
    end,
    __index = function(_, n)
        return global[n];
    end
})
]]--

