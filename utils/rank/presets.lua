local RT = require 'utils.rank.table'
local Public = require 'utils.rank.main'

function Public._add_group(group) local this = RT.get_table() if game then return end table.insert(this.groups, group) end
function Public._add_rank(rank,pos) local this = RT.get_table() if game then return end if pos then table.insert(this.ranks,pos,rank) else table.insert(this.ranks,rank) end end
function Public._set_rank_power() local this = RT.get_table() if game then return end for power,rank in pairs(this.ranks) do rank.power = power end end
function Public._update_rank(rank) local this = RT.get_table() if game then return end this.ranks[rank.power] = rank end
function Public._update_group(group) local this = RT.get_table() if game then return end this.groups[group.index] = group end

local root = Public._group:create{
    name='Root',
    allow={
        ['interface'] = true
    }
}
local admin = Public._group:create{
    name='Admin',
    disallow={
        'set_allow_commands',
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group'
    }
}
local user = Public._group:create{
    name='User',
    disallow={
        'set_allow_commands',
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group',
        'edit_custom_tag'
    }
}
local jail = Public._group:create{
    name='Jail',
    disallow={
        'set_allow_commands',
        'edit_permission_group',
        'delete_permission_group',
        'add_permission_group',
        'open_character_gui',
        'begin_mining',
        'start_walking',
        'player_leave_game',
        'open_blueprint_library_gui',
        'build_item',
        'use_item',
        'select_item',
        'rotate_entity',
        'open_train_gui',
        'open_train_station_gui',
        'open_gui',
        'open_item',
        'deconstruct',
        'build_rail',
        'cancel_research',
        'start_research',
        'set_train_stopped',
        'select_gun',
        'open_technology_gui',
        'open_trains_gui',
        'edit_custom_tag',
        'craft',
        'setup_assembling_machine'
    }
}

root:add_rank{
    name='Root',
    short_hand='Root',
    tag='',
    colour={r=179,g=125,b=46},
    is_root=true,
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}
admin:add_rank{
    name='Admin',
    short_hand='Admin',
    tag='',
    colour={r=233,g=63,b=233},
    is_admin=true,
    is_spectator=true,
    base_afk_time=false
}
user:add_rank{
    name='Members',
    short_hand='Members',
    tag='',
    colour={r=24,g=172,b=188},
	is_default=true,
    disallow={},
    base_afk_time=30
}
jail:add_rank{
    name='Jail',
    short_hand='Jail',
    tag='[Jail]',
    colour={r=50,g=50,b=50},
    disallow={},
    base_afk_time=1
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
function Public._groups(name)
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

function Public._ranks(name)
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

function Public._meta()
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

Public._meta()

return Public