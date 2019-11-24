-- oarc_enemies_tick_logic.lua
-- Aug 2019
--
-- Holds all the code related to the the on_tick "state machine"
-- Where we process on going attacks step by step.
local Table = require 'map_gen.mps_0_17.lib.table'
local OE_Table = require 'features.modules.oarc_enemies.table'
local Utils = require 'map_gen.mps_0_17.lib.oarc_utils'
local OE = require 'features.modules.oarc_enemies.oarc_enemies'
local Evo = require 'features.modules.oarc_enemies.oarc_enemies_evo'
local Surface = require 'utils.surface'.get_surface_name()

local Public = {}

function Public.OarcEnemiesOnTick()
    local global_data = Table.get_table()

    -- Cleanup attacks that have died or somehow become invalid.
    if ((game.tick % (global_data.ticks_per_second)) == 20) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackCleanupInvalidGroups(key, attack) then break end
        end
    end

    -- Process player timers
    if ((game.tick % (global_data.ticks_per_second)) == 21) then
        Public.ProcessPlayerTimersEverySecond()
    end

    -- process_find_target
    -- Find target given request type
    if ((game.tick % (global_data.ticks_per_second)) == 22) then
        for key,attack in pairs(global.oe.attacks) do
            if not key then break end
            if not attack then break end
            if Public.ProcessAttackFindTarget(key, attack) then break end
        end
    end

    -- process_find_spawn
    -- Find spawn location
    if ((game.tick % (global_data.ticks_per_second)) == 23) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackFindSpawn(key, attack) then break end
        end
    end

    -- process_find_spawn_path_req
    -- Find path
    if ((game.tick % (global_data.ticks_per_second)) == 24) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackCheckPathFromSpawn(key, attack) then break end
        end
    end

    -- process_find_spawn_path_calc -- WAIT FOR EVENT
    -- Event Function: ProcessAttackCheckPathComplete(event)

    -- process_find_create_group
    -- Spawn group
    if ((game.tick % (global_data.ticks_per_second)) == 25) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackCreateGroup(key, attack) then break end
        end
    end

    -- process_find_command_group
    -- Send group on attack
    if ((game.tick % (global_data.ticks_per_second)) == 26) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackCommandGroup(key, attack) then break end
        end
    end

    -- process_find_group_active -- ACTIVE STATE, WAIT FOR EVENT
    -- Event Function: OarcEnemiesGroupCmdFailed(event)

    -- process_find_command_failed
    -- Handle failed groups?
    if ((game.tick % (global_data.ticks_per_second)) == 27) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackCommandFailed(key, attack) then break end
        end
    end

    -- process_find_fallback_attack
    -- Attempt fallback attack on general area of target
    if ((game.tick % (global_data.ticks_per_second)) == 28) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackFallbackAttack(key, attack) then break end
        end
    end

    -- process_find_fallback_final
    -- Final fallback just abandons attack and sets the group to autonomous
    if ((game.tick % (global_data.ticks_per_second)) == 29) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackFallbackAuto(key, attack) then break end
        end
    end

    -- process_find_retry_path_req
    -- Handle pathing retries
    if ((game.tick % (global_data.ticks_per_second)) == 30) then
        for key,attack in pairs(global.oe.attacks) do
            if Public.ProcessAttackRetryPath(key, attack) then break end
        end
    end

    -- process_find_retry_path_calc -- WAIT FOR EVENT
    -- Event Function: ProcessAttackCheckPathComplete(event)

end


function Public.ProcessAttackCleanupInvalidGroups(key, attack)
    local Def = OE_Table.get_table()
    if (attack.process_stg ~= Def.process_find_group_active) and
        (attack.process_stg ~= Def.process_find_build_base) then return false end

    if (not attack.group or not attack.group.valid) then
        if global.oe.debug then
            log("ProcessAttackCleanupInvalidGroups - Group killed?")
        end
        table.remove(global.oe.attacks, key)
        return true

    elseif (attack.group.state == defines.group_state.wander_in_group) then
        if global.oe.debug then
            log("ProcessAttackCleanupInvalidGroups - Group done (wandering)?")
        end
        OE.EnemyGroupBuildBaseThenWander(attack.group, attack.group.position)
        global.oe.attacks[key].process_stg = Def.process_find_build_base
        return true
    end

    return false
end

function Public.ProcessPlayerTimersEverySecond()
    local Def = OE_Table.get_table()
    local global_data = Table.get_table()
    for name,timer_table in pairs(global.oe.player_timers) do
        if (game.players[name] and game.players[name].connected) then

            for timer_name,timer in pairs(timer_table) do
                if (timer > 0) then
                    global.oe.player_timers[name][timer_name] = timer-1
                else
                    if (timer_name == "character") then
                        OE.OarcEnemiesPlayerAttackCharacter(name)
                        global.oe.player_timers[name][timer_name] =
                            Evo.GetRandomizedPlayerTimer(game.players[name].online_time/global_data.ticks_per_second, 0)

                    elseif (timer_name == "generic") then
                        OE.OarcEnemiesBuildingAttack(name, Def.enemy_targets)
                        global.oe.player_timers[name][timer_name] =
                            Evo.GetRandomizedPlayerTimer(game.players[name].online_time/global_data.ticks_per_second, 0)
                    end
                end
            end
        end
    end
end

function Public.ProcessAttackFindTarget(key, attack)
    local Def = OE_Table.get_table()

    if (attack.process_stg ~= Def.process_find_target) then return false end

    -- log("tick_log ProcessAttackFindTarget " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ATTACK FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    if (attack.target_player and attack.target_type) then

        local player = game.players[attack.target_player]

        -- Attack a building of the player, given a certain building type
        if (attack.target_type == Def.type_target_building) then

            local random_building = OE.GetRandomBuildingAny(attack.target_player,
                                                            attack.building_types)

            if (random_building ~= nil) then
                global.oe.attacks[key].target_entity = random_building

                local e,s = Evo.GetEnemyGroup{player=player,
                                            force_name=player.force.name,
                                            surface=player.surface,
                                            target_pos=random_building.position}

                global.oe.attacks[key].size = s
                global.oe.attacks[key].evo = e
                global.oe.attacks[key].process_stg = Def.process_find_spawn
                return true
            else
                if global.oe.debug then
                    log("No building found to attack.")
                end
                table.remove(global.oe.attacks, key)
            end

        -- Attack a player directly
        elseif (attack.target_type == Def.type_target_player) then

            global.oe.attacks[key].target_entity = player.character

            local e,s = Evo.GetEnemyGroup{player=player,
                                            force_name=player.force.name,
                                            surface=game.surfaces[Surface],
                                            target_pos=player.position}

            global.oe.attacks[key].size = s
            global.oe.attacks[key].evo = e
            global.oe.attacks[key].process_stg = Def.process_find_spawn
            return true
        end

    else
        if global.oe.debug then
            log("ERROR - Missing info in attack - target_player or target_type!" .. key)
        end
    end

    return false
end


function Public.ProcessAttackFindSpawn(key, attack)
    local Def = OE_Table.get_table()

    if (attack.process_stg ~= Def.process_find_spawn) then return false end

    -- log("tick_log ProcessAttackFindSpawn " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ProcessAttackFindSpawn FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    if (attack.target_entity or attack.target_chunk) then

        -- Invalid entity check?
        if (attack.target_entity and not attack.target_entity.valid) then
            global.oe.attacks[key].target_entity = nil
            global.oe.attacks[key].attempts = attack.attempts - 1
            global.oe.attacks[key].process_stg = Def.process_find_target
            return false
        end

        -- Use entity or target chunk info to start search
        local c_pos
        if (attack.target_entity) then
            c_pos = Utils.GetChunkPosFromTilePos(attack.target_entity.position)
            global.oe.attacks[key].target_chunk = c_pos -- ALWAYS SET FOR BACKUP
        elseif (attack.target_chunk) then
            c_pos = attack.target_chunk
        end
        local spawns = OE.SpiralSearch(c_pos, Def.search_radius_chunks, 5, OE.OarcEnemiesDoesChunkHaveSpawner)

        if (spawns ~= nil) then
            global.oe.attacks[key].spawn_chunk = spawns[Utils.GetRandomKeyFromTable(spawns)]
            global.oe.attacks[key].process_stg = Def.process_find_spawn_path_req
        else
            if global.oe.debug then
                log("Could not find a spawn near target...")
            end
            global.oe.attacks[key].target_entity = nil
            global.oe.attacks[key].attempts = attack.attempts - 1
            global.oe.attacks[key].process_stg = Def.process_find_target
        end

        return true
    else
        if global.oe.debug then
            log("Missing attack info: target_entity or target_chunk!" .. key)
        end
    end

    return false
end


function Public.ProcessAttackCheckPathFromSpawn(key, attack)
    local Def = OE_Table.get_table()

    if (attack.process_stg ~= Def.process_find_spawn_path_req) then return false end

    -- log("tick_log ProcessAttackCheckPathFromSpawn " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ProcessAttackCheckPathFromSpawn FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    if (attack.spawn_chunk) then

        -- Check group doesn't already exist
        if (attack.group and attack.group_id and attack.group.valid) then
            if global.oe.debug then
                log("ERROR - group should not be valid - ProcessAttackCheckPathFromSpawn!")
            end
            table.remove(global.oe.attacks, key)
            return false
        end

        -- Find a large area that is free to spawn biters in
        local spawn_pos = game.surfaces[Surface].find_non_colliding_position("rocket-silo",
                                            Utils.GetCenterTilePosFromChunkPos(attack.spawn_chunk),
                                            32,
                                            1)
        global.oe.attacks[key].spawn_pos = spawn_pos

        if (not spawn_pos) then
            if global.oe.debug then
                log("No space to spawn? ProcessAttackCheckPathFromSpawn")
            end
            global.oe.attacks[key].attempts = attack.attempts - 1
            return false
        end

        local target_pos = nil
        if (attack.target_entity and attack.target_entity.valid) then
            target_pos = attack.target_entity.position
        elseif (attack.target_chunk) then
            target_pos = Utils.GetCenterTilePosFromChunkPos(attack.target_chunk)
        end

        if (not target_pos) then
            if global.oe.debug then
                log("Lost target during ProcessAttackCheckPathFromSpawn")
            end
            global.oe.attacks[key].target_entity = nil
            global.oe.attacks[key].target_chunk = nil
            global.oe.attacks[key].attempts = attack.attempts - 1
            global.oe.attacks[key].process_stg = Def.process_find_target
            return false
        end

        global.oe.attacks[key].path_id = game.surfaces[Surface].request_path{bounding_box={{0,0},{0,0}},
                                                        collision_mask={"player-layer"},
                                                        start=spawn_pos,
                                                        goal=target_pos,
                                                        force=game.forces["enemy"],
                                                        radius=8,
                                                        pathfind_flags={low_priority=true},
                                                        can_open_gates=false,
                                                        path_resolution_modifier=-1}
        global.oe.attacks[key].process_stg = Def.process_find_spawn_path_calc
        return true
    else
        if global.oe.debug then
            log("ERROR - Missing attack info: spawn_chunk or path_id!" .. key)
        end
    end

    return false
end


function Public.ProcessAttackCheckPathComplete(event)
    local Def = OE_Table.get_table()
    local global_data = Table.get_table()
    if (not event.id) then return end
    local path_success = (event.path ~= nil)

    -- Debug help info
    if (path_success) then
        if (global.oe_render_paths) then
            Utils.RenderPath(event.path, global_data.ticks_per_minute, game.connected_players)
        end
    else
        if global.oe.debug then
            log("ERROR - on_script_path_request_finished: FAILED")
            if (event.try_again_later) then
                log("ERROR - on_script_path_request_finished: TRY AGAIN LATER?")
            end
        end
    end

    for key,attack in pairs(global.oe.attacks) do
        if (attack.path_id == event.id) then

            local group_exists_already = (attack.group and attack.group_id and attack.group.valid)

            -- First time path check before a group is spawned
            if (attack.process_stg == Def.process_find_spawn_path_calc) then
                if (group_exists_already) then
                    if global.oe.debug then
                    log("ERROR - Def.process_find_spawn_path_calc has a valid group?!")
                    end
                end

                if (path_success) then
                    global.oe.attacks[key].path = event.path
                    global.oe.attacks[key].process_stg = Def.process_find_create_group
                else
                    global.oe.attacks[key].path_id = nil
                    global.oe.attacks[key].attempts = attack.attempts - 1
                    global.oe.attacks[key].process_stg = Def.process_find_target
                end

            -- Retry path check on a command failure
            elseif  (attack.process_stg == Def.process_find_retry_path_calc) then

                if (not group_exists_already) then
                    if global.oe.debug then
                        log("ERROR - process_find_retry_path_calc has NO valid group?!")
                    end
                end

                if (path_success) then
                    global.oe.attacks[key].path = event.path
                    global.oe.attacks[key].process_stg = Def.process_find_command_group
                else
                    if global.oe.debug then
                        log("Group can no longer path to target. Performing fallback attack instead" .. attack.group.group_id)
                    end
                    global.oe.attacks[key].path_id = nil
                    global.oe.attacks[key].attempts = attack.attempts - 1
                    global.oe.attacks[key].process_stg = Def.process_find_fallback_attack
                end

            else
                if global.oe.debug then
                    log("Path calculated but process stage is wrong!??!")
                end
            end

            return
        end
    end
end


function Public.ProcessAttackCreateGroup(key, attack)
    local Def = OE_Table.get_table()
    if (attack.process_stg ~= Def.process_find_create_group) then return false end

    -- log("tick_log ProcessAttackCreateGroup " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ProcessAttackCreateGroup FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    if (attack.group_id == nil) then
        local group = OE.CreateEnemyGroupGivenEvoAndCount(game.surfaces[Surface],
                                                        attack.spawn_pos,
                                                        attack.evo,
                                                        attack.size)
        global.oe.attacks[key].group_id = group.group_number
        global.oe.attacks[key].group = group
        global.oe.attacks[key].process_stg = Def.process_find_command_group

        -- On the first time the player has a direct attack, warn them?
        if (attack.target_type == Def.type_target_player) and
           (not global.oe.player_sbubbles[attack.target_player].uh_oh) then
            Utils.DisplaySpeechBubble(game.players[attack.target_player],
                                "Uh oh... I feel something comming after me!", 10)
            global.oe.player_sbubbles[attack.target_player].uh_oh = true
        end

        return true
    else
        if global.oe.debug then
            log("ERROR - ProcessAttackCreateGroup already has a group?" .. key)
        end
    end

    return false
end


function Public.ProcessAttackCommandGroup(key, attack)
    local Def = OE_Table.get_table()
    local global_data = Table.get_table()
    if (attack.process_stg ~= Def.process_find_command_group) then return false end

    -- log("tick_log ProcessAttackCommandGroup " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ProcessAttackCommandGroup FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    -- Sanity check we have a group and a path
    if (attack.group_id and attack.group and attack.group.valid) then

        -- If we have a target entity, attack that.
        if (attack.target_entity and attack.target_entity.valid and attack.path_id) then
            OE.EnemyGroupGoAttackEntityThenWander(attack.group, attack.target_entity, attack.path)
            global.oe.attacks[key].process_stg = Def.process_find_group_active
            return true

        -- If we have a target chunk, attack that area.
        elseif (attack.target_chunk) then
            OE.EnemyGroupAttackAreaThenWander(attack.group,
                                            Utils.GetCenterTilePosFromChunkPos(attack.target_chunk),
                                            global_data.chunk_size*2)
            global.oe.attacks[key].process_stg = Def.process_find_group_active
            return true

        -- Otherwise, shit's fucked
        else
            if global.oe.debug then
                log("ProcessAttackCommandGroup invalid target?" .. key)
            end
            global.oe.attacks[key].path_id = nil
            global.oe.attacks[key].attempts = attack.attempts - 1
            global.oe.attacks[key].process_stg = Def.process_find_target
            return false
        end
    else
        if global.oe.debug then
            log("ProcessAttackCommandGroup invalid group?" .. key)
        end
    end

    return false
end


function Public.OarcEnemiesGroupCmdFailed(event)
    local Def = OE_Table.get_table()
    local attack_key = OE.FindAttackKeyFromGroupIdNumber(event.unit_number)

    -- This group cmd failure is not associated with an attack. Must be a unit or something.
    if (not attack_key) then return end

    local attack = global.oe.attacks[attack_key]

    -- Is group no longer valid?
    if (not attack.group or not attack.group.valid) then
        if global.oe.debug then
            log("OarcEnemiesGroupCmdFailed group not valid anymore")
        end
        table.remove(global.oe.attacks, attack_key)
        return
    end

    -- Check if it's a fallback attack.
    if (attack.target_type == Def.type_target_area) then

        global.oe.attacks[attack_key].process_stg = Def.process_find_fallback_final

    -- Else handle failure based on attack type.
    else
        global.oe.attacks[attack_key].process_stg = Def.process_find_command_failed
    end
end


function Public.ProcessAttackCommandFailed(key, attack)
    local Def = OE_Table.get_table()
    if (attack.process_stg ~= Def.process_find_command_failed) then return false end

    -- log("tick_log ProcessAttackCommandFailed " .. game.tick)

    if (attack.attempts == 0) then
        if global.oe.debug then
            log("attack.attempts = 0 - ProcessAttackCommandFailed FAILURE")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    -- If we fail to attack the player, it likely means the player moved.
    -- So we try to retry pathing so we can "chase" the player.
    if (attack.target_type == Def.type_target_player) then
        global.oe.attacks[key].process_stg = Def.process_find_retry_path_req
        return true

    -- Fallback for all other attack types is to attack the general area instead.
    -- Might add other special cases here later.
    else
        if global.oe.debug then
            log("ProcessAttackCommandFailed - performing fallback now?")
        end
        global.oe.attacks[key].attempts = attack.attempts - 1
        global.oe.attacks[key].process_stg = Def.process_find_fallback_attack
        return true
    end

    return false
end


function Public.ProcessAttackFallbackAttack(key, attack)
    local Def = OE_Table.get_table()
    local global_data = Table.get_table()
    if (attack.process_stg ~= Def.process_find_fallback_attack) then return false end

    -- log("tick_log ProcessAttackFallbackAttack " .. game.tick)

    if (attack.group_id and attack.group and attack.group.valid and attack.target_chunk) then

        OE.EnemyGroupAttackAreaThenWander(attack.group,
                                      Utils.GetCenterTilePosFromChunkPos(attack.target_chunk),
                                      global_data.chunk_size*2)
        global.oe.attacks[key].target_type = Def.type_target_area
        global.oe.attacks[key].process_stg = Def.process_find_group_active
        return true
    else
        if global.oe.debug then
            log("ProcessAttackFallbackAttack invalid group or target?" .. key)
        end
    end

    return false
end


function Public.ProcessAttackFallbackAuto(key, attack)
    local Def = OE_Table.get_table()
    if (attack.process_stg ~= Def.process_find_fallback_final) then return false end

    -- log("tick_log ProcessAttackFallbackAuto " .. game.tick)

    if (attack.group and attack.group.valid) then
        if global.oe.debug then
            log("ProcessAttackFallbackAuto - Group now autonomous...")
        end
        attack.group.set_autonomous()
    else
        if global.oe.debug then
            log("ProcessAttackFallbackAuto - Group no longer valid!")
        end
    end

    table.remove(global.oe.attacks, key)
    return true
end


function Public.ProcessAttackRetryPath(key, attack)
    local Def = OE_Table.get_table()

    if (attack.process_stg ~= Def.process_find_retry_path_req) then return false end

    -- log("tick_log ProcessAttackRetryPath " .. game.tick)

    -- Validation checks
    if ((attack.target_type ~= Def.type_target_player) or
        (attack.attempts == 0) or
        (not attack.target_entity) or
        (not attack.target_entity.valid)) then
        if global.oe.debug then
            log("ProcessAttackRetryPath FAILURE")
        end
        if (attack.group and attack.group.valid) then
            attack.group.set_autonomous()
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    -- Check group still exists
    if (attack.group and attack.group_id and attack.group.valid) then

        -- Path request
        global.oe.attacks[key].path_id =
            game.surfaces[Surface].request_path{bounding_box={{0,0},{0,0}},
                                            collision_mask={"player-layer"},
                                            start=attack.group.members[1].position,
                                            goal=attack.target_entity.position,
                                            force=game.forces["enemy"],
                                            radius=8,
                                            pathfind_flags={low_priority=true},
                                            can_open_gates=false,
                                            path_resolution_modifier=-1}
        global.oe.attacks[key].process_stg = Def.process_find_retry_path_calc
        return true

    else
        if global.oe.debug then
            log("ERROR - group should BE valid - ProcessAttackRetryPath!")
        end
        table.remove(global.oe.attacks, key)
        return false
    end

    return false
end

return Public