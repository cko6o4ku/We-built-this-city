local Event = require 'utils.event'
local Surface = require 'utils.surface'.get_surface_name()
local Table = require 'utils.surface'
require 'map_gen.shapes.metaconfig'
local Eval = require 'map_gen.shapes.evalpattern'

local map_name = 'natural medium lakes'
local water_color = 'green'

local get_tile = nil
local force_initial_water = false
local mabs = math.abs
local insert = table.insert
local math_random = math.random

local function replace_water(surface)
    if global.spawn_water_replaced then return end
    if not surface.is_chunk_generated({5,5}) then return end
    local tilename
    for x = -50, 50, 1 do
        for y = -50, 50, 1 do
            local tile = surface.get_tile(x, y)
            if tile.name ~= "water" and tile.name ~= "deepwater" then
                tilename = tile.name
            end
        end
    end
    local tiles = {}
    for x = -128, 128, 1 do
        for y = -128, 128, 1 do
            local tile = surface.get_tile(x, y)
            if tile.name == "water" or tile.name == "water-green" or tile.name == "deepwater" or tile.name == "deepwater-green" then
                insert(tiles, {name = tilename, position = {x = tile.position.x, y = tile.position.y}})
            end
        end
    end
    surface.set_tiles(tiles, true)
    global.spawn_water_replaced = true
end

local function make_chunk(event)
    local gt = get_tile
    local tinsert = table.insert
    if not game.surfaces[Surface] then return end

    local surface = game.surfaces[Surface]

    local x1 = event.area.left_top.x
    local y1 = event.area.left_top.y
    local x2 = event.area.right_bottom.x
    local y2 = event.area.right_bottom.y

    local tiles = {}
    local fishes = {}

    if mabs(x1) + mabs(y1) > 70 then
        for x = x1, x2 do
            for y = y1, y2 do
                local new = gt(x, y)
                if new ~= nil then
                    tinsert(tiles, {name = new, position = {x, y}})
                    if math_random(1,1024) == 1 then tinsert(fishes, {x, y}) end
                end
            end
        end

    else
        -- Only happens for a few chunks near the origin
        for x = x1, x2 do
            for y = y1, y2 do
                if force_initial_water and ((x - 7) * (x - 7) + y * y < 10) then
                    tinsert(tiles, {name = water_color, position = {x, y}})
                else
                    if (x * x + y * y > 5) then
                        local new = gt(x, y)
                        if new ~= nil then
                            tinsert(tiles, {name = new, position = {x, y}})
                        end
                    end
                end
            end
        end
    end

    surface.set_tiles(tiles)

    for _, fish in pairs(fishes) do
        surface.create_entity({name = "fish", position = fish})
    end
end

local function on_load()
        local tp = Eval.evaluate_pattern(map_name)
        tp.reload(global.tp_data)
        get_tile = tp.get

end

local function on_init()
    local t = Table.get()
        t.water = 0
        local tp = Eval.evaluate_pattern(map_name)
        global.tp_data = tp.create()
        get_tile = tp.get
end

Event.on_init(on_init)

Event.on_load(on_load)

Event.add(defines.events.on_chunk_generated, function(event)
    make_chunk(event)
    replace_water(game.surfaces[Surface])
end
)