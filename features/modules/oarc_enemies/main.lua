local Event = require 'utils.event'
--local Table = require 'features.modules.oarc_enemies.table'
local Evo = require 'features.modules.oarc_enemies.oarc_enemies_evo'
local OE = require 'features.modules.oarc_enemies.oarc_enemies'
--local Gui = require 'features.modules.oarc_enemies.oarc_enemies_gui'
local Logic = require 'features.modules.oarc_enemies.oarc_enemies_tick_logic'
local Utils = require 'map_gen.mps_0_17.lib.oarc_utils'


Event.on_init(function()
    OE.init_all_the_tables()
end)

Event.add(defines.events.on_player_created, function(event)
    OE.OarcEnemiesPlayerCreatedEvent(event)
end)

--Event.add(defines.events.on_player_joined_game, function(event)
--    Gui.OarcEnemiesCreateGui(event)
--end)
--
--Event.add(defines.events.on_gui_click, function(event)
--    Gui.OarcEnemiesGuiClick(event)
--end)

Event.add(defines.events.on_chunk_generated, function(event)
    OE.OarcEnemiesChunkGenerated(event)
end)

Event.add(defines.events.on_built_entity, function (event)
    local e = event.created_entity
    if e and e.valid then
        if ((e.type ~= "car") and
            (e.type ~= "logistic-robot") and
            (e.type ~= "construction-robot") and
            (e.type ~= "combat-robot")) then
            OE.OarcEnemiesChunkHasPlayerBuilding(e.position)
        end
        OE.OarcEnemiesTrackBuildings(e)
    end
end)

Event.add(defines.events.on_robot_built_entity, function (event)
    local e = event.created_entity
    if e and e.valid then
        if ((e.type ~= "car") and
            (e.type ~= "logistic-robot") and
            (e.type ~= "construction-robot") and
            (e.type ~= "combat-robot")) then
            OE.OarcEnemiesChunkHasPlayerBuilding(e.position)
        end
        OE.OarcEnemiesTrackBuildings(e)
    end
end)

Event.add(defines.events.script_raised_built, function(event)
    OE.OarcEnemiesChunkHasPlayerBuilding(event.entity.position)
end)

Event.add(defines.events.on_biter_base_built, function(event)
    OE.OarcEnemiesBiterBaseBuilt(event)
end)

Event.add(defines.events.on_entity_spawned, function(event)
    local entity = event.entity
    if not entity then return end
    entity.destroy()
end)

Event.add(defines.events.on_entity_died, function(event)
    OE.OarcEnemiesEntityDiedEvent(event)
end)

--Event.add(defines.events.on_unit_group_created, function(event)
--    OE.OarcEnemiesGroupCreatedEvent(event)
--end)

Event.add(defines.events.on_unit_removed_from_group, function(event)
    OE.OarcEnemiesUnitRemoveFromGroupEvent(event)
end)

-- Event.add(defines.events.on_unit_added_to_group, function(event)
    -- Maybe use this to track all units I've created so I can clean up later if needed?
    -- log("Unit added to group? " .. event.unit.name .. event.unit.position.x.. event.unit.position.y)
-- end)

Event.add(defines.events.on_ai_command_completed, function(event)
    if (event.result == defines.behavior_result.fail) then
        Logic.OarcEnemiesGroupCmdFailed(event)
    end
end)

Event.add(defines.events.on_tick, function()
    Logic.OarcEnemiesOnTick()
    Utils.TimeoutSpeechBubblesOnTick()
end)

Event.add(defines.events.on_script_path_request_finished, function(event)
    Logic.ProcessAttackCheckPathComplete(event)
end)


Event.add(defines.events.on_research_finished, function(event)
   OE.OarcEnemiesResearchFinishedEvent(event)
end)


Event.add(defines.events.on_force_created, function(event)
    OE.OarcEnemiesForceCreated(event)
end)

Event.add(defines.events.on_sector_scanned, function (event)
    OE.OarcEnemiesSectorScanned(event)
end)

Event.add(defines.events.on_rocket_launched, function(event)
    OE.OarcEnemiesRocketLaunched(event)
end)