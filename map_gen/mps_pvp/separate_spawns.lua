local table_insert = table.insert
local math_ceil = math.ceil
local table_remove = table.remove
local SPAWN_GUI_MAX_WIDTH = 500
local SPAWN_GUI_MAX_HEIGHT = 1000


-- Check if the player has a different spawn point than the default one
-- Make sure to give the default starting items
function SeparateSpawnsPlayerRespawned(event)
    local player = game.players[event.player_index]
    SendPlayerToSpawn(player.name)
end


-- This is the main function that creates the spawn area
-- Provides resources, land and a safe zone
function SeparateSpawnsGenerateChunk(event)
    local surface = game.surfaces["nauvis"]
    local chunkArea = event.area
    
    -- This handles chunk generation near player spawns
    -- If it is near a player spawn, it does a few things like make the area
    -- safe and provide a guaranteed area of land and water tiles.
    SetupAndClearSpawnAreas(surface, chunkArea)
end

--------------------------------------------------------------------------------
-- NON-EVENT RELATED FUNCTIONS
--------------------------------------------------------------------------------

-- Add a spawn to the shared spawn global
-- Used for tracking which players are assigned to it, where it is and if
-- it is open for new players to join
function CreateNewSharedSpawn(player)
    global.sharedSpawns[player.name] = {openAccess=true,
                                    position=global.playerSpawns[player.name],
                                    players={}}
end

function TransferOwnershipOfSharedSpawn(prevOwnerName, newOwnerName)
    -- Transfer the shared spawn global
    global.sharedSpawns[newOwnerName] = global.sharedSpawns[prevOwnerName]
    global.sharedSpawns[newOwnerName].openAccess = false
    global.sharedSpawns[prevOwnerName] = nil

    -- Transfer the unique spawn global
    global.uniqueSpawns[newOwnerName] = global.uniqueSpawns[prevOwnerName]
    global.uniqueSpawns[prevOwnerName] = nil

    game.players[newOwnerName].print("You have been given ownership of this base!")
end

-- Returns the number of players currently online at the shared spawn
function GetOnlinePlayersAtSharedSpawn(ownerName)
    if (global.sharedSpawns[ownerName] ~= nil) then

        -- Does not count base owner
        local count = 0

        -- For each player in the shared spawn, check if online and add to count.
        for _,player in pairs(game.connected_players) do
            if (ownerName == player.name) then
                count = count + 1
            end

            for _,playerName in pairs(global.sharedSpawns[ownerName].players) do
            
                if (playerName == player.name) then
                    count = count + 1
                end
            end
        end

        return count
    else
        return 0
    end
end

-- Get the number of currently available shared spawns
-- This means the base owner has enabled access AND the number of online players
-- is below the threshold.
function GetNumberOfAvailableSharedSpawns()
    local count = 0

    for ownerName,sharedSpawn in pairs(global.sharedSpawns) do
        if (sharedSpawn.openAccess and
            (game.players[ownerName] ~= nil) and
            game.players[ownerName].connected) then
            if ((MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN == 0) or
                (GetOnlinePlayersAtSharedSpawn(ownerName) < MAX_ONLINE_PLAYERS_AT_SHARED_SPAWN)) then
                count = count+1
            end
        end
    end

    return count
end


-- Initializes the globals used to track the special spawn and player
-- status information
function InitSpawnGlobalsAndForces()
    -- Containes an array of all player spawns
    -- A secondary array tracks whether the character will respawn there.
    if (global.playerSpawns == nil) then
        global.playerSpawns = {}
    end
    if (global.uniqueSpawns == nil) then
        global.uniqueSpawns = {}
    end
    if (global.sharedSpawns == nil) then
        global.sharedSpawns = {}
    end
    if (global.unusedSpawns == nil) then
        global.unusedSpawns = {}
    end
    if (global.playerCooldowns == nil) then
        global.playerCooldowns = {}
    end
    if (global.delayedSpawns == nil) then
        global.delayedSpawns = {}
    end

    local gameForce = game.create_force(MAIN_FORCE)

    gameForce.set_spawn_position(game.forces["player"].get_spawn_position(g_surface), g_surface)
end


function DoesPlayerHaveCustomSpawn(player)
    for name,spawnPos in pairs(global.playerSpawns) do
        if (player.name == name) then
            return true
        end
    end
    return false
end

function ChangePlayerSpawn(player, pos)
    global.playerSpawns[player.name] = pos
    global.playerCooldowns[player.name] = {setRespawn=game.tick}
end

local function DisplayPleaseWaitForSpawnDialog(player, delay_seconds)
    
    local wait_warning_text = "Moving you into the void in... " .. delay_seconds .. " seconds\n"
    SendMsg(player.name, wait_warning_text)
end

function QueuePlayerForDelayedSpawn(playerName, spawn, moatEnabled)
    
    -- If we get a valid spawn point, setup the area
    if ((spawn.x ~= 0) and (spawn.y ~= 0)) then
        global.uniqueSpawns[playerName] = {pos=spawn,moat=moatEnabled}

        local delay_spawn_seconds = 2*(math_ceil(ENFORCE_LAND_AREA_TILE_DIST/CHUNK_SIZE))

        game.surfaces["nauvis"].request_to_generate_chunks(spawn, 2)
        delayedTick = game.tick + delay_spawn_seconds*TICKS_PER_SECOND
        table_insert(global.delayedSpawns, {playerName=playerName, spawn=spawn, moatEnabled=moatEnabled, delayedTick=delayedTick})

        DisplayPleaseWaitForSpawnDialog(game.players[playerName], delay_spawn_seconds)

    else      
        SendBroadcastMsg("Failed to create spawn point for: " .. playerName)
    end
end

local function SendPlayerToNewSpawnAndCreateIt(playerName, spawn, moatEnabled)

    -- Make sure the area is super safe.
    ClearNearbyEnemies(spawn, SAFE_AREA_TILE_DIST, game.surfaces[g_surface])
    if ENABLE_RES then
    CreateWaterStrip(game.surfaces[g_surface],
                    {x=spawn.x+WATER_SPAWN_OFFSET_X, y=spawn.y+WATER_SPAWN_OFFSET_Y},
                    WATER_SPAWN_LENGTH)
    CreateWaterStrip(game.surfaces[g_surface],
                    {x=spawn.x+WATER_SPAWN_OFFSET_X, y=spawn.y+WATER_SPAWN_OFFSET_Y+1},
                    WATER_SPAWN_LENGTH)
    end

    


    -- Send the player to that position
    --game.players[playerName].teleport(spawn, g_surface)
    --GivePlayerStarterItems(game.players[playerName])

    -- Chart the area.
    --ChartArea(game.players[playerName].force, game.players[playerName].position, math_ceil(ENFORCE_LAND_AREA_TILE_DIST/CHUNK_SIZE), game.players[playerName].surface)

    --permission_group = game.permissions.get_group("Default")    
    --permission_group.add_player(tostring(playerName))
    -- Create the spawn resources here
    if ENABLE_RES then
    GenerateStartingResources(surface, spawn)
    end
end

-- Check a table to see if there are any players waiting to spawn
-- Check if we are past the delayed tick count
-- Spawn the players and remove them from the table.
function DelayedSpawnOnTick()
    if ((game.tick % (30)) == 1) then
        if ((global.delayedSpawns ~= nil) and (#global.delayedSpawns > 0)) then
            for i=#global.delayedSpawns,1,-1 do
                delayedSpawn = global.delayedSpawns[i]

                if (delayedSpawn.delayedTick < game.tick) then
                    -- TODO, add check here for if chunks around spawn are generated surface.is_chunk_generated(chunkPos)
                    if (game.players[delayedSpawn.playerName] ~= nil) then
                        SendPlayerToNewSpawnAndCreateIt(delayedSpawn.playerName, delayedSpawn.spawn, delayedSpawn.moatEnabled)
                    end
                    table_remove(global.delayedSpawns, i)
                end
            end
        end
    end
end

function SendPlayerToSpawn(player)
    if (game.forces[player].get_spawn_position(game.surfaces["nauvis"]) ~= {0,0}) then
        local p = g_surface.find_non_colliding_position("player", game.forces[player], 15, 1)
        player.teleport(p, g_surface)
    else
        --player.teleport(game.forces[MAIN_FORCE].get_spawn_position(g_surface), g_surface)
    end
end

function SendPlayerToRandomSpawn(player)
    local numSpawns = TableLength(global.uniqueSpawns)
    local rndSpawn = math.random(0,numSpawns)
    local counter = 0

    if (rndSpawn == 0) then
        player.teleport(game.forces[MAIN_FORCE].get_spawn_position(g_surface), g_surface)
    else
        counter = counter + 1
        for name,spawn in pairs(global.uniqueSpawns) do
            if (counter == rndSpawn) then
                player.teleport(spawn.pos)
                break
            end
            counter = counter + 1
        end 
    end
end

local function IsSharedSpawnActive(player)
    if ((global.sharedSpawns[player.name] == nil) or
        (global.sharedSpawns[player.name].openAccess == false)) then
        return false
    else
        return true
    end
end


-- Get a random warp point to go to
function GetRandomSpawnPoint()
    local numSpawnPoints = TableLength(global.sharedSpawns)
    if (numSpawnPoints > 0) then
        local randSpawnNum = math.random(1,numSpawnPoints)
        local counter = 1
        for _,sharedSpawn in pairs(global.sharedSpawns) do
            if (randSpawnNum == counter) then
                return sharedSpawn.position
            end
            counter = counter + 1
        end
    end

    return {x=0,y=0}
end

