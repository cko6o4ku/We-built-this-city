local event = require 'utils.event'
local Task = require 'utils.task'
local Token = require 'utils.token'

local random = math.random
local set_timeout_in_ticks = Task.set_timeout_in_ticks
local ceil = math.ceil

local entity_spawn_map = {
    ['medium-biter'] = {name = 'small-biter', count = 2, chance = 1},
    ['big-biter'] = {name = 'medium-biter', count = 2, chance = 1},
    ['behemoth-biter'] = {name = 'big-biter', count = 2, chance = 1},
    ['medium-spitter'] = {name = 'small-worm-turret', count = 1, chance = 0.2},
    ['big-spitter'] = {name = 'medium-worm-turret', count = 1, chance = 0.2},
    ['behemoth-spitter'] = {name = 'big-worm-turret', count = 1, chance = 0.2},
    ['biter-spawner'] = {type = 'biter', count = 5, chance = 1},
    ['spitter-spawner'] = {type = 'spitter', count = 5, chance = 1},
    ['stone-furnace'] = {type = 'cause', count = 2, chance = 1},
    ['steel-furnace'] = {type = 'cause', count = 2, chance = 1},
    ['electric-furnace'] = {type = 'cause', count = 4, chance = 1},
    ['assembling-machine-1'] = {type = 'cause', count = 4, chance = 1},
    ['assembling-machine-2'] = {type = 'cause', count = 4, chance = 1},
    ['assembling-machine-3'] = {type = 'cause', count = 4, chance = 1},
    ['chemical-plant'] = {type = 'cause', count = 4, chance = 1},
    ['centrifuge'] = {type = 'cause', count = 6, chance = 1},
    ['pumpjack'] = {type = 'cause', count = 6, chance = 1},
    ['storage-tank'] = {type = 'cause', count = 4, chance = 1},
    ['oil-refinery'] = {type = 'cause', count = 8, chance = 1},
    ['offshore-pump'] = {type = 'cause', count = 2, chance = 1},
    ['boiler'] = {type = 'cause', count = 2, chance = 1},
    ['heat-exchanger'] = {type = 'cause', count = 4, chance = 1},
    ['steam-engine'] = {type = 'cause', count = 6, chance = 1},
    ['steam-turbine'] = {type = 'cause', count = 10, chance = 1},
    ['nuclear-reactor'] = {type = 'cause', count = 20, chance = 1},
    ['rocket-silo'] = {type = 'cause', count = 40, chance = 1},
    ['train-stop'] = {type = 'cause', count = 2, chance = 1},
    ['burner-mining-drill'] = {type = 'cause', count = 2, chance = 1},
    ['electric-mining-drill'] = {type = 'cause', count = 4, chance = 1},
    ['lab'] = {type = 'cause', count = 6, chance = 1},
    ['solar-panel'] = {type = 'cause', count = 4, chance = 1},
    ['accumulator'] = {type = 'cause', count = 2, chance = 1},
    ['beacon'] = {type = 'cause', count = 6, chance = 1},
    ['radar'] = {type = 'cause', count = 4, chance = 1}
}

local unit_levels = {
    biter = {
        'small-biter',
        'medium-biter',
        'big-biter',
        'behemoth-biter'
    },
    spitter = {
        'small-spitter',
        'medium-spitter',
        'big-spitter',
        'behemoth-spitter'
    }
}

local worms = {
    ['small-worm-turret'] = true,
    ['medium-worm-turret'] = true,
    ['big-worm-turret'] = true
}

local allowed_cause_source = {
    ['small-biter'] = true,
    ['medium-biter'] = true,
    ['big-biter'] = true,
    ['behemoth-biter'] = true,
    ['small-spitter'] = true,
    ['medium-spitter'] = true,
    ['big-spitter'] = true,
    ['behemoth-spitter'] = true
}

local turret_evolution_factor = {
    ['gun-turret'] = 0.001,
    ['laser-turret'] = 0.002,
    ['flamethrower-turret'] = 0.0015,
    ['artillery-turret'] = 0.004
}

local spawn_worm =
    Token.register(
    function(data)
        local surface = data.surface
        local name = data.name
        local position = data.position

        local p = surface.find_non_colliding_position(name, position, 8, 1)

        if p then
            local entity = surface.create_entity({name = data.name, position = data.position})
        end
    end
)

local function get_level()
    local ef = game.forces.enemy.evolution_factor
    if ef == 0 then
        return 1
    else
        return ceil(ef * 4)
    end
end

local spawn_units =
    Token.register(
    function(data)
        local surface = data.surface
        local name = data.name
        local position = data.position
        for _ = 1, data.count do
            local p = surface.find_non_colliding_position(name, position, 8, 1)
            if p then
                surface.create_entity {name = name, position = p}
            end
        end
    end
)

local function spawn_ents (event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end
    local entity_force = entity.force
    local entity_name = entity.name
    local factor = turret_evolution_factor[entity_name]
    if factor then
        if entity_force.name == 'enemy' then
            local old = entity_force.evolution_factor
            local new = old + (1 - old) * factor
            entity_force.evolution_factor = math.min(new, 1)
        end
    end
    local spawn = entity_spawn_map[entity_name]
    if spawn then
        local chance = spawn.chance
        if chance == 1 or random() <= chance then
            local name = spawn.name
            if name == nil then
                local type = spawn.type
                if type == 'cause' then
                    local cause = event.cause
                    if not cause then
                        return
                    end
                    name = cause.name
                    if not allowed_cause_source[cause.name] then
                        return
                    end
                else
                    name = unit_levels[type][get_level()]
                end
            end
            if worms[name] then
                set_timeout_in_ticks(
                    5,
                    spawn_worm,
                    {surface = entity.surface, name = name, position = entity.position}
                )
            else
                set_timeout_in_ticks(
                    5,
                    spawn_units,
                    {surface = entity.surface, name = name, position = entity.position, count = spawn.count}
                )
            end
        end
    end
end

event.add(defines.events.on_entity_died, spawn_ents)