local RT = require 'utils.rank.table'
local Color = require 'utils.color_presets'
local Public = require 'utils.rank.main'

function Public._add_group(group) local this = RT.get_table() if game then return end table.insert(this.groups,group) end
function Public._add_rank(rank,pos) local this = RT.get_table() if game then return end if pos then table.insert(this.ranks,pos,rank) else table.insert(this.ranks,rank) end end
function Public._set_rank_power() local this = RT.get_table() if game then return end for power,rank in pairs(this.ranks) do rank.power = power end end
function Public._update_rank(rank) local this = RT.get_table() if game then return end this.ranks[rank.power] = rank end
function Public._update_group(group) local this = RT.get_table() if game then return end this.groups[group.index] = group end

local root = Public._group:create{
    name='Root',
    allow={
        ['interface'] = true
    },
    disallow={}
}
local admin = Public._group:create{
    name='Admin',
    allow={},
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}
local user = Public._group:create{
    name='User',
    allow={},
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}
local jail = Public._group:create{
    name='Jail',
    allow={},
    disallow={
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group',
        'open_character_gui',
        'begin_mining',
        'start_walking',
        'open_blueprint_library_gui',
        'build_item',
        'use_item',
        'select_item',
        'rotate_entity',
        'select_blueprint_entities',
        'open_train_gui',
        'open_train_station_gui',
        'open_gui',
        'open_item',
        'deconstruct',
        'build_rail',
        'cancel_research',
        'start_research',
        'set_train_stopped',
        'select_next_valid_gun',
        'open_technology_gui',
        'open_trains_gui',
        'edit_custom_tag',
        'craft',
        'setup_assembling_machine',
    }
}

-- If you wish to add more ranks please use addons/playerRanks.lua
-- If you wish to add to these rank use addons/playerRanks.lua
root:add_rank{
    name='Root',
    short_hand='Root',
    tag='[Root]',
    colour=Color.white,
    is_root=true,
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}

admin:add_rank{
    name='Admin',
    short_hand='Admin',
    tag='[Admin]',
    colour={r=233,g=63,b=233},
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}

user:add_rank{
    name='Member',
    short_hand='Mem',
    tag='[Member]',
    colour={r=24,g=172,b=188},
    disallow={
        'set_auto_launch_rocket',
        'change_programmable_speaker_alert_parameters',
        'drop_item'
    },
    base_afk_time=60
}
user:add_rank{
    name='Rookie',
    short_hand='',
    tag='',
    colour={r=185,g=187,b=160},
    is_default=true,
    disallow={
        'build_terrain',
        'remove_cables',
        'launch_rocket',
        'reset_assembling_machine',
        'cancel_research'
    },
    base_afk_time=10
}

jail:add_rank{
    name='Jail',
    short_hand='Jail',
    tag='[Jail]',
    colour={r=50,g=50,b=50},
    disallow={},
    base_afk_time=false
}

function Public._auto_edit_ranks()
    local this = RT.get_table()
    for power,rank in pairs(this.ranks) do
        if this.ranks[power-1] then
            rank:edit('disallow',false,this.ranks[power-1].disallow)
        end
    end
    for power = #this.ranks, 1, -1 do
        local rank = this.ranks[power]
        rank:edit('disallow',false,rank.group.disallow)
        if this.ranks[power+1] then
            rank:edit('allow',false,this.ranks[power+1].allow)
        end
    end
end

-- used to force rank to be read-only
function Public.add_groups(name)
    local this = RT.get_table()
    if name then
        if name then
            local _return = {}
            for _, group in pairs(this.groups) do
                _return[group.name] = group
            end
            return _return
        end
    end
    return this.groups
end

function Public.add_ranks(name)
    local this = RT.get_table()
    if name then
        local _return = {}
        for _, rank in pairs(this.ranks) do
            _return[rank.name] = rank
        end
        return _return
    end
    return this.ranks
end

function Public._metadata()
    local this = RT.get_table()
    local meta = this.meta
    if not meta.time_ranks then
        meta.time_ranks = {}
    end
    for power,rank in pairs(this.ranks) do
        meta.rank_count = power
        if rank.is_default then
            meta.default = rank.name
        end
        if rank.is_root then
            meta.root = rank.name
        end
        if rank.time then
            table.insert(meta.time_ranks,rank.name)
            if not meta.time_highest or power < meta.time_highest then meta.time_highest = power end
            if not meta.time_lowest or rank.time < meta.time_lowest then meta.time_lowest = rank.time end
        end
    end
    return meta
end

return Public