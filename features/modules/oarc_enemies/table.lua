-- oarc_enemies_defines.lua
-- Aug 2019
-- Some hard settings and general definitions and stuff.

-- Max number of ongoing attacks at any time.

local Global = require 'utils.global'

local Public = {}

local global_data = {
    max_attacks = 30,
    max_attacks_retal = 150,
    safe_area_radius = 3,
    search_radius_chunks = 35,
    type_target_player       = 1,
    type_target_area         = 2,
    type_target_building     = 3,
    type_target_unknown       = 4,
    type_target_entity       = 5,
    process_find_target      = 0,
    process_find_spawn       = 1,
    process_find_spawn_path_req   = 2,
    process_find_spawn_path_calc  = 3,
    process_find_create_group     = 4,
    process_find_command_group        = 5,
    process_find_group_active     = 6,
    process_find_command_failed       = 7,
    process_find_fallback_attack  = 8,
    process_find_fallback_final   = 9,
    process_find_retry_path_req   = 10,
    process_find_retry_path_calc  = 11,
    process_find_build_base       = 12,
    enemy_targets = {"ammo-turret", "boiler", "electric-turret", "fluid-turret", "artillery-turret", "mining-drill", "furnace", "reactor", "assembling-machine", "generator"},
    debug = true,
}

Global.register(
    global_data,
    function(tbl)
        global_data = tbl
    end
)

function Public.get_table()
    return global_data
end

return Public