local Server = require 'utils.server'
local Callback = require 'utils.callback_token'
local Color = require 'utils.color_presets'
local Event = require "utils.event"
local Table = require 'utils.extended_table'
local RT = require 'utils.rank.table'

local Public = {}

Public.events = {rank_change = Event.generate_event_name('rank_change')}
Public._rank = {}
Public._group = {}

local function p_log(string)
    if not __DEBUG then return end
    return log("P_LOG: " .. serpent.block(string))
end

local function s_log(string)
    if not __DEBUG then return end
    return log("S_LOG: " .. serpent.block(string))
end

local function tick_to_min(tick)
    if not Server.is_type(tick,'number') then return 0 end
    return math.floor(tick/(3600*game.speed))
end

function Public.output_ranks(player)
    local this = RT.get_table()
    local _player = player or game.player.name
    if not _player then return end
    for power,rank in pairs(this.ranks) do
        local output = power..') '..rank.name
        output=output..' '..rank.tag
        local admin = 'No'; if rank.is_root then admin = 'Root' elseif rank.is_admin then admin = 'Yes' end
        output=output..' Admin: '..admin
        output=output..' Group: '..rank.group.name
        output=output..' AFK: '..tostring(rank.base_afk_time)
        Server.player_return(output,rank.colour,_player)
    end
end

function Public.add_ranks(names)
    local this = RT.get_table()
    return this.ranks
end

function Public.add_groups(names)
    local this = RT.get_table()
    return this.groups
end

function Public.standard_ranks(table)
    local this = RT.get_table()
    this.current = table
end

function Public._presets()
    local this = RT.get_table()
    return this
end

function Public.get_rank(player)
    local this = RT.get_table()
    if not player then return false end
    local _ranks = Public.add_ranks(true)
    local _return
    if Server.is_type(player,'table') then
        if player.index then
            _return = game.players[player.index] and _ranks[player.permission_group.name] or nil
        else
            _return = player.group and player or nil
        end
    else
        _return = game.players[player] and _ranks[game.players[player].permission_group.name]
        or Table.autokey(_ranks,player) and Table.autokey(_ranks,player)
        or string.contains(player,'server') and Public.get_rank(this.meta.root)
        or string.contains(player,'root') and Public.get_rank(this.meta.root)
        or nil
    end
    return _return
end

function Public.get_group(mixed)
    if not mixed then return false end
    local _groups = Public.add_groups(true)
    local rank = Public.get_rank(mixed)
    return rank and rank.group
    or Server.is_type(mixed,'table') and mixed.ranks and mixed
    or Server.is_type(mixed,'string') and Table.autokey(_groups,mixed) and Table.autokey(_groups,mixed)
    or false
end

function Public.print(rank_base,rtn,colour,below)
    local _colour = colour or Color.white
    local _rank_base = Public.get_rank(rank_base)
    local ranks = Public.add_ranks()
    if below then
        for power,rank in pairs(ranks) do
            if _rank_base.power <= power then rank:print(rtn,_colour,true) end
        end
    else
        for power,rank in pairs(ranks) do
            if _rank_base.power >= power then rank:print(rtn,_colour) end
        end
    end
end

-- @usage Ranking.give_rank(1,'member')
function Public.give_rank(player,rank,by_player,tick)
    local this = RT.get_table()
    local print_colour = Color.info
    local tick = tick or game.tick
    local by_player_name = 'script' or player.name or Server.is_type(by_player,'string') and by_player
    local rank = Public.get_rank(rank) or Public.get_rank(this.meta.default)
    local old_rank = Public.get_rank(player) or Public.get_rank(this.meta.default)
    local message = 'Ranking.rank-down'
    -- messaging
    if old_rank.name == rank.name then return end
    if rank.power < old_rank.power then message = 'ranking.rank-up' player.play_sound{path='utility/achievement_unlocked'}
    else player.play_sound{path='utility/game_lost'} end
    if player.online_time > 60 or by_player_name ~= 'server' then game.print({message,player.name,rank.name,by_player_name},print_colour) end
    if rank.group.name ~= 'User' then Server.player_return({'ranking.rank-given',rank.name},print_colour,player) end
    if player.tag ~= old_rank.tag then Server.player_return({'ranking.tag-reset'},print_colour,player) end
    -- rank change
    player.permission_group = game.permissions.get_group(rank.name)
    player.tag = rank.tag
    if old_rank.group.name ~= 'Jail' then this.old[player.index] = old_rank.name end
    player.admin = rank.is_admin or false
    player.spectator = rank.is_spectator or false
    if Public.events.rank_change then
        script.raise_event(Public.events.rank_change,{
            name=Public.events.rank_change,
            tick=tick,
            player_index=player.index,
            by_player_name=by_player_name,
            new_rank=rank,
            old_rank=old_rank
        })
    end
end

function Public.revert(player,by_player)
    local this = RT.get_table()
    local _player = game.get_player(player)
    Public.give_rank(_player,this.old[_player.index],by_player)
end

function Public.find_preset(player,tick)
    local this = RT.get_table()
    local presets = this.current
    local meta_data = this.meta
    local default = Public.get_rank(meta_data.default)
    local current_rank = Public.get_rank(player) or {power=-1,group={name='not jail'}}
    local _ranks = {default}
    if current_rank.group.name == 'Jail' then return end
    if presets[string.lower(player.name)] then
        local rank = Public.get_rank(presets[string.lower(player.name)])
        table.insert(_ranks,rank)
    end
    if not meta_data.time_highest then return end
    if current_rank.power > meta_data.time_highest and tick_to_min(player.online_time) > meta_data.time_lowest then
        for _,rank_name in pairs(meta_data.time__ranks) do
            local rank = Public.get_rank(rank_name)
            if tick_to_min(player.online_time) > rank.time then
                table.insert(_ranks,rank)
            end
        end
    end
    local _rank = current_rank
    for _,rank in pairs(_ranks) do
        if rank.power < _rank.power or _rank.power == -1 then _rank = rank end
    end
    if _rank then
        if _rank.name == default.name then
            player.tag = _rank.tag
            player.permission_group = game.permissions.get_group(_rank.name)
        else
            Public.give_rank(player,_rank,nil,tick)
        end
    end
end

function Public._rank:allowed(action)
    return self.allow[action] or self.is_root or false
end

function Public._rank:get_players(online)
    local players = game.permissions.get_group(self.name).players
    local _return = {}
    if online then
        for _,player in pairs(players) do
            if player.connected then table.insert(_return,player) end
        end
    else
        _return = players
    end
    return _return
end

function Public._rank:print(rtn,colour,show_default)
    local this = RT.get_table()
    local colour = colour or Color.white
    local meta_data = this.meta
    local default = Public.get_rank(meta_data.default)
    if not Callback or not Callback._thread then
        for _,player in pairs(self:get_players(true)) do
            if self.name == default.name or show_default then
                Server.player_return({'Public.all-rank-print',rtn},colour,player)
            else
                Server.player_return({'Public.rank-print',self.name,rtn},colour,player)
            end
        end
    else
        -- using threads to make less lag
        Callback.new_thread{
            data={rank=self,rtn=rtn,default=default.name,all=show_default}
        }:on_event('resolve',function(thread)
            return thread.data.rank:get_players(true)
        end):on_event('success',function(thread,players)
            for _,player in pairs(players) do
                if thread.data.rank.name == thread.data.default or thread.data.all then
                    Server.player_return({'Public.all-rank-print',thread.data.rtn},colour,player)
                else
                    Server.player_return({'Public.rank-print',thread.data.rank.name,thread.data.rtn},colour,player)
                end
            end
        end):queue()
    end
end

function Public._rank:edit(key,set_value,value)
    if game then return end
    p_log('Edited Rank: '..self.name..'/'..key)
    if set_value then self[key] = value return end
    if key == 'disallow' then
        if value ~= {} then
            self.disallow = Table.merge(self.disallow, value)
        end
    elseif key == 'allow' then
        self.allow = Table.merge(self.allow, value)
    end
    Public._update_rank(self)
end

function Public._group:create(obj)
    local this = RT.get_table()
    if game then return end
    if not Server.is_type(obj.name,'string') then return end
    p_log('Created Group: '..obj.name)
    setmetatable(obj,{__index=Public._group})
    self.index = #this.groups+1
    obj.ranks = {}
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    Public._add_group(obj)
    return obj
end

function Public._group:add_rank(obj)
    if game then return end
    if not Server.is_type(obj.name,'string') or
    not Server.is_type(obj.short_hand,'string') or
    not Server.is_type(obj.tag,'string') or
    not Server.is_type(obj.colour,'table') then return end
    p_log('Created Rank: '..obj.name)
    setmetatable(obj,{__index=Public._rank})
    obj.group = self
    obj.allow = obj.allow or {}
    obj.disallow = obj.disallow or {}
    s_log(self.highest)
    obj.power = obj.power and self.highest and self.highest.power+obj.power or obj.power or self.lowest and self.lowest.power+1 or nil
    setmetatable(obj.allow,{__index=self.allow})
    setmetatable(obj.disallow,{__index=self.disallow})
    Public._add_rank(obj,obj.power)
    Public._set_rank_power()
    table.insert(self.ranks,obj)
    if not self.highest or obj.power < self.highest.power then self.highest = obj end
    if not self.lowest or obj.power > self.lowest.power then self.lowest = obj end
end

function Public._group:edit(key,set_value,value)
    if game then return end
    p_log('Edited Group: '..self.name..'/'..key)
    if set_value then self[key] = value return end
    if key == 'disallow' then
        self.disallow = Table.merge(self.disallow,value,true)
    elseif key == 'allow' then
        self.allow = Table.merge(self.allow,value)
    end
    Public._update_group(self)
end

Event.add(defines.events.on_player_joined_game,function(event)
    local player = game.players[event.player_index]
    if not player then
        return
    end
    Public.find_preset(player)
end)

Event.on_init(function()
    Public._metadata()
    local this = RT.get_table()
    for _, rank in pairs(this.ranks) do
        local perm = game.permissions.create_group(rank.name)
        for _, toRemove in pairs(rank.disallow) do
            if rank ~= nil then
                perm.set_allows_action(defines.input_action[toRemove],false)
            end
        end
    end
end)

Event.add(defines.events.on_tick,function(event)
    if (((event.tick+10)/(3600*game.speed))+(15/2))% 15 == 0 then
        if not Callback or not Callback._thread then
            for _,player in pairs(game.connected_players) do
                Public.find_preset(player)
            end
        else
            Callback.new_thread{
                data={players=game.connected_players}
            }:on_event('tick',function(thread)
                if #thread.data.players == 0 then thread:close() return end
                local player = table.remove(thread.data.players,1)
                Public.find_preset(player)
            end):open()
        end
    end
end)

return Public