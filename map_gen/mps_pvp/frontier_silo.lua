-- frontier_silo.lua
-- Jan 2018
-- My take on frontier silos for my Oarc scenario
--------------------------------------------------------------------------------
-- Frontier style rocket silo stuff
--------------------------------------------------------------------------------

-- This creates a random silo position, stored to global.siloPosition
-- It uses the config setting SILO_CHUNK_DISTANCE and spawns the silo somewhere
-- on a circle edge with radius using that distance.
function SetRandomSiloPosition(num_silos)
    if (global.siloPosition == nil) then

        global.siloPosition = {}

        random_angle_offset = math.random(0, math.pi * 2)

        for i=1,num_silos do
            theta = ((math.pi * 2) / num_silos);
            angle = (theta * i) + random_angle_offset;

            tx = (SILO_CHUNK_DISTANCE*CHUNK_SIZE * math.cos(angle))
            ty = (SILO_CHUNK_DISTANCE*CHUNK_SIZE * math.sin(angle))

            table.insert(global.siloPosition, {x=math.floor(tx), y=math.floor(ty)})

            log("Silo position: " .. tx .. ", " .. ty .. ", " .. angle)
        end
    end
end

-- Sets the global.siloPosition var to the set in the config file
function SetFixedSiloPosition(pos)
    if (global.siloPosition == nil) then
        global.siloPosition = {}
        table.insert(global.siloPosition, SILO_POSITION)
    end
end

-- Create a rocket silo at the specified positionmmmm
-- Also makes sure tiles and entities are cleared if required.
function CreateRocketSilo(surface, siloPosition, force)

    -- Delete any entities beneath the silo?
    for _, entity in pairs(surface.find_entities_filtered{area = {{siloPosition.x-5,
                                                                    siloPosition.y-6},
                                                                    {siloPosition.x+6,
                                                                    siloPosition.y+6}}}) do
        entity.destroy()
    end

    -- Remove nearby enemies again
    for _, entity in pairs(surface.find_entities_filtered{area = {{siloPosition.x-(CHUNK_SIZE*4),
                                                                    siloPosition.y-(CHUNK_SIZE*4)},
                                                                    {siloPosition.x+(CHUNK_SIZE*4),
                                                                    siloPosition.y+(CHUNK_SIZE*4)}}, force = "enemy"}) do
        entity.destroy()
    end

    -- Set tiles below the silo
    tiles = {}
    i = 1
    for dx = -5,5 do
        for dy = -6,5 do
            tiles[i] = {name = "concrete", position = {siloPosition.x+dx, siloPosition.y+dy}}
            i=i+1
        end
    end
    surface.set_tiles(tiles, true)

    -- Create silo and assign to a force
    silo = surface.create_entity{name = "rocket-silo", position = {siloPosition.x+0.5, siloPosition.y}, force = force}
    silo.destructible = true
    silo.minable = false

    if ENABLE_SILO_TURRETS then
        Defense(surface, siloPosition, game.forces["Protectors"])
    end
        
end

-- Generates all rocket silos, should be called after the areas are generated
-- Includes a crop circle
function GenerateAllSilos(surface)                       
    
    -- Create each silo in the list
    for idx,siloPos in pairs(global.siloPosition) do
        CreateRocketSilo(surface, siloPos, "Protectors")
    end
end

-- Generate clean land and trees around silo area on chunk generate event
function GenerateRocketSiloChunk(event)

    -- Silo generation can take awhile depending on the number of silos.
    if (game.tick < SILO_NUM_SPAWNS*2*TICKS_PER_SECOND) then
        local surface = event.surface
        local chunkArea = event.area

        local chunkAreaCenter = {x=chunkArea.left_top.x+(CHUNK_SIZE/2),
                                 y=chunkArea.left_top.y+(CHUNK_SIZE/2)}
        
        for idx,siloPos in pairs(global.siloPosition) do
            local safeArea = {left_top=
                                {x=siloPos.x-(CHUNK_SIZE*4),
                                 y=siloPos.y-(CHUNK_SIZE*4)},
                              right_bottom=
                                {x=siloPos.x+(CHUNK_SIZE*4),
                                 y=siloPos.y+(CHUNK_SIZE*4)}}
                                     

            -- Clear enemies directly next to the rocket
            if CheckIfInArea(chunkAreaCenter,safeArea) then
                for _, entity in pairs(surface.find_entities_filtered{area = chunkArea, force = "enemy"}) do
                    entity.destroy()
                end

                -- Remove trees/resources inside the spawn area
                RemoveInCircle(surface, chunkArea, "tree", siloPos, ENFORCE_LAND_AREA_TILE_DIST+5)
                RemoveInCircle(surface, chunkArea, "simple-entity", siloPos, ENFORCE_LAND_AREA_TILE_DIST+5)
                RemoveInCircle(surface, chunkArea, "resource", siloPos, ENFORCE_LAND_AREA_TILE_DIST+5)
                RemoveInCircle(surface, chunkArea, "cliff", siloPos, ENFORCE_LAND_AREA_TILE_DIST+5)
                RemoveDecorationsArea(surface, chunkArea)

                -- Create rocket silo
                CreateCropOctagon(surface, siloPos, chunkArea, CHUNK_SIZE*2)
            end
        end
    end
end

-- Generate chunks where we plan to place the rocket silos.
function GenerateRocketSiloAreas(surface)
    for idx,siloPos in pairs(global.siloPosition) do
        if (ENABLE_SILO_VISION) then
            for name, force in pairs(game.forces) do
            if name ~= "neutral" and name ~= "enemy" then
                ChartRocketSiloAreas(surface, force)
            end
        end
    end
        surface.request_to_generate_chunks({siloPos.x, siloPos.y}, 3)
    end
end

-- Chart chunks where we plan to place the rocket silos.
function ChartRocketSiloAreas(surface, force)
    for idx,siloPos in pairs(global.siloPosition) do
        force.chart(surface, {{siloPos.x-(CHUNK_SIZE*2),
                                siloPos.y-(CHUNK_SIZE*2)},
                                {siloPos.x+(CHUNK_SIZE*2),
                                siloPos.y+(CHUNK_SIZE*2)}})
    end
end

global.silos_generated = false
function DelayedSiloCreationOnTick(event)

    -- Delay the creation of the silos so we place them on already generated lands.
    if (not global.silos_generated and (game.tick >= SILO_NUM_SPAWNS*2*TICKS_PER_SECOND)) then
        DebugPrint("Frontier silos generated!")
        global.silos_generated = true
        GenerateAllSilos(game.surfaces[g_surface])
    end
end 

function Defense(surface, siloPos, force)

    -- Add Turrets
    -- x = right, left; y = up, down
    -- top 1 left 1
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-8, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- top 2
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-5, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- top 3
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-2, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- top 4
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+2, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- top 5
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+5, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- top 6 right 1
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+8, siloPos.y-9}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 2
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-6, siloPos.y-6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 3
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-6, siloPos.y-3}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 4
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-6, siloPos.y}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 5
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-6, siloPos.y+3}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 6 bottom 1
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-8, siloPos.y+6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- left 7 bottom 2
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x-5, siloPos.y+6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 2
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+6, siloPos.y-6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 3
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+6, siloPos.y-3}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 4
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+6, siloPos.y}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 5
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+6, siloPos.y+3}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 6 bottom 3
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+5, siloPos.y+6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
    -- right 7 bottom 4
    local e = surface.create_entity{name = "gun-turret", position = {siloPos.x+8, siloPos.y+6}, force = force}
    e.insert({name = "piercing-rounds-magazine", count = math.random(64, 128)})
    e.destructible = true
    e.minable = true
end