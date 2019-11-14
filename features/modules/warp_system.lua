require "mod-gui"
local event = require 'utils.event'
local Global = require 'utils.global'
local warp_tiles = {
    {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
    {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
}

local warp_entities = {
    {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
    {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
    {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
}

local warp_radius = 4
local warp_tile = 'tutorial-grid'
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}

local warp_table = {}
local dataset = nil
local indexes = {}

Global.register({
    warp_table=warp_table,
    dataset=dataset,
    indexes=indexes
},function(tbl)
    warp_table = tbl.warp_table
    indexes = tbl.indexes
end)

local function remove_warp_point(name)
    local warp = warp_table[name]
    if not warp then return end
    local base_tile = warp.old_tile
    local surface =  warp.surface
    local offset = warp.position
    local tiles = {}
    if name == 'Spawn' then return end
    for x = -warp_radius-2, warp_radius+2 do
        for y = -warp_radius-2, warp_radius+2 do
            if x^2+y^2 < (warp_radius+1)^2 then
                table.insert(tiles,{name=base_tile,position={x+offset.x,y+offset.y}})
                local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                for _,entity in pairs(entities) do if entity.name ~= 'character' then entity.destroy() end end
                --or entity.name ~= 'player' or entity.name ~= 'bob-character-fighter' or entity.name ~= 'bob-character-miner' or entity.name ~= 'bob-character-builder'
            end
        end
    end
    surface.set_tiles(tiles)
    if warp.tag.valid then warp.tag.destroy() end
    warp_table[name] = nil
end

local function make_warp_point(position,surface,force,name)
    local warp = warp_table[name]
    if warp then return end
    local offset = {x=math.floor(position.x),y=math.floor(position.y)}
    local old_tile = surface.get_tile(offset).name
    local base_tiles = {}
    local tiles = {}
    -- this makes the base template to make the warp point
    for x = -warp_radius-2, warp_radius+2 do
        for y = -warp_radius-2, warp_radius+2 do
            if x^2+y^2 < warp_radius^2 then
                table.insert(base_tiles,{name=warp_tile,position={x+offset.x,y+offset.y}})
            end
        end
    end
    surface.set_tiles(base_tiles)
    -- this adds the patterns and entities
    for _,position in pairs(warp_tiles) do
        table.insert(tiles,{name=warp_tile,position={position[1]+offset.x+global_offset.x,position[2]+offset.y+global_offset.y}})
    end
    surface.set_tiles(tiles)
    for _,entity in pairs(warp_entities) do
        local entity = surface.create_entity{name=entity[1],position={entity[2]+offset.x+global_offset.x,entity[3]+offset.y+global_offset.y},force='neutral'}
        entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
    end
    local tag = force.add_chart_tag(surface,{
        position={offset.x+0.5,offset.y+0.5},
        text='Warp: '..name,
        icon={type='item',name=warp_item}
    })
    warp_table[name] = {tag=tag,position=tag.position,surface=surface,old_tile=old_tile}
end

local function create_warp_button(player)
    local mod_gui = indexes[player.name].mod_gui
    local button = mod_gui.warp_button
    if button then
        button.destroy()
    end
    local b = mod_gui.add{
    type = "sprite-button",
    sprite = "item/discharge-defense-equipment",
    name = "warp_button",
    tooltip = "Warp to places!"
    }
    b.style.font_color = {r = 0.1, g = 0.8, b = 0.1}
    b.style.font = "heading-1"
    b.style.minimal_height = 38
    b.style.minimal_width = 38
    b.style.top_padding = 2
    b.style.left_padding = 4
    b.style.right_padding = 4
    b.style.bottom_padding = 2
end

local function create_gui(player, mod_gui)
    local mod_gui = indexes[player.name].mod_gui
    local menu_frame = mod_gui.warp_list_gui
    if menu_frame then
        menu_frame.destroy()
    end

    local menu_frame = mod_gui.add{
    type = "frame",
    name = "warp_list_gui",
    direction = "vertical"
    }

    local tbl = menu_frame.add{
    type = "table",
    column_count = 10
    }

    local l = tbl.add{
    type = "label",
    caption = "Warps: "
    }
    l.style.font_color = { r=0.98, g=0.66, b=0.22}
    l.style.font = "default-listbox"

    local _flows1 = tbl.add{
    type = 'flow'
    }
    _flows1.style.minimal_width = 150
    _flows1.style.horizontally_stretchable = true

    local _flows2 = tbl.add{
    type = 'flow'
    }

    local btn = _flows2.add{
    type = "sprite-button",
    name = "add_warp_gui",
    sprite='utility/add',
    tooltip = "Add a new warp point!",
    align = "right"
    }
    btn.style.height = 20
    btn.style.width = 20

    local ts = menu_frame.add{
    type = "table",
    column_count = 1
    }

    local f = ts.add{
    type = "frame",
    column_count = 2
    }

    local t = f.add{
    type = "table",
    column_count = 10
    }

    local warp_list = t.add{
    type = 'scroll-pane',
    direction = 'vertical',
    vertical_scroll_policy = 'auto',
    horizontal_scroll_policy = 'never'
    }
    warp_list.vertical_scroll_policy = 'auto'
    warp_list.style.maximal_height = 200

    local table = warp_list.add{
    type = 'table',
    column_count = 3
    }
    for name,warp in pairs(warp_table) do
        if not warp.tag or not warp.tag.valid then
            player.force.add_chart_tag(warp.surface,{
                position=warp.position,
                text='Warp: '..name,
                icon={type='item',name=warp_item}
            })
        end
        local lb = table.add{
            type='label',
            caption=name,
            style='caption_label'
        }

        local _flows3 = table.add{
            type='flow'
        }
        _flows3.style.minimal_width = 105

        local _flows = table.add{
            type='flow',
            name=name
        }
        local btn = _flows.add{
        type = "sprite-button",
        name = "go_to_warp_gui",
        tooltip = "Goto!",
        sprite='utility/export_slot'
        }
        btn.style.height = 20
        btn.style.width = 20
        if _flows.name ~= "Spawn" then
            btn = _flows.add{
            type = "sprite-button",
            name = "remove_warp_gui",
            tooltip = "Remove!",
            sprite='utility/remove'
            }
            btn.style.height = 20
            btn.style.width = 20
        else
            local btn = _flows.add{
            type = "sprite-button",
            name = "remove_warp_gui",
            enabled = "false",
            tooltip = "Disabled.",
            sprite='utility/remove'
            }
            btn.style.height = 20
            btn.style.width = 20
        end
        if indexes[player.name].removing == true then
            if _flows.name == dataset then
                if player.admin or indexes[player.name].trusted then
                    local btn = _flows.add{
                    type = "sprite-button",
                    name = "confirmed",
                    tooltip = "Are you sure?",
                    sprite='utility/confirm_slot'
                    }
                    btn.style.height = 20
                    btn.style.width = 20
                else
                    local btn = _flows.add{
                    type = "sprite-button",
                    name = "confirmed",
                    enabled = "false",
                    tooltip = "Your not trusted yet!",
                    sprite='utility/set_bar_slot'
                    }
                    btn.style.height = 20
                    btn.style.width = 20
                end
                indexes[player.name].removing = false
            end
        end

        if indexes[player.name].creating == true then
            if player.admin or indexes[player.name].trusted then
                local position = player.position
                local posx = position.x
                local posy = position.y
                local dist2 = 100^2

                for name,warp_id in pairs(warp_table) do
                    local pos = warp_id.position
                    if (posx-pos.x)^2+(posy-pos.y)^2 < dist2 then
                        player.print('Too close to another warp: ' .. name , {r=0.22, g=0.99, b=0.99})
                        indexes[player.name].creating = false
                        refresh_gui()
                        return
                    end
                end

                local frame = menu_frame.add{
                type = "frame",
                name = "wp_name",
                direction = "vertical"
                }

                local x = frame.add{
                type = "table",
                name = "wp_table",
                column_count = 4
                }

                local textfield = x.add{
                type = "textfield",
                name = "wp_text",
                text = "Warp name:"
                }
                textfield.style.minimal_width = 30
                textfield.style.height = 24
                textfield.style.horizontally_stretchable = true

                local _flow = x.add{
                type = 'flow'
                }

                local _flows3 = _flow.add{
                type = 'flow'
                }

                local btn = _flow.add{
                type = "sprite-button",
                name = "add_warp_func",
                tooltip = "Creates a new warp point.",
                sprite='utility/downloaded'
                }
                btn.style.height = 20
                btn.style.width = 20

                indexes[player.name].creating = false
            end
        end
    end
end

local function on_player_joined_game(event)
    local player = game.players[event.player_index]
    if not indexes[player.name] then
        indexes[player.name] = {
        creating=false,
        removing=false,
        mod_gui=mod_gui.get_frame_flow(player),
        trusted=false
        }
    end
    create_warp_button(player)
    local playtime = player.online_time
    if playtime > 2592000 then
        indexes[player.name].trusted = true
        refresh_gui_player(player)
    end
end

local function on_gui_click(event)
    local player = game.players[event.element.player_index]
    local mod_gui = indexes[player.name].mod_gui
    local menu_frame = mod_gui.warp_list_gui
    local frame = event.element.parent.name
    dataset = frame
    local warp = warp_table[frame]
    if not event then return end
    if not event.element then return end
    if not event.element.valid then return end

        if event.element.name == "warp_button" then
            if not menu_frame then
                create_gui(player, mod_gui)
            else
                menu_frame.destroy()
            end
            if indexes[player.name].removing == true then
                indexes[player.name].removing = false 
            end
            return
        end
        if event.element.name == "remove_warp_gui" then
            if not indexes[player.name].removing == true then indexes[player.name].removing = true end
            refresh_gui_player(player)
            return
        end

        if event.element.name == "confirmed" then
        remove_warp_point(frame)
        if indexes[player.name].removing == true then
            indexes[player.name].removing = false 
        end
        refresh_gui()
        return
        end

        if event.element.name == "go_to_warp_gui" then
        if not indexes[player.name].removing == true then indexes[player.name].removing = false end
        refresh_gui()
        local position = player.position
        if (warp.position.x - position.x)^2 + (warp.position.y - position.y)^2 < 1024 then
        player.print('Destination is source warp: ' .. frame, {r=0.22, g=0.99, b=0.99})
        return end
        if player.vehicle then player.vehicle.set_driver(nil) end
        if player.vehicle then player.vehicle.set_passenger(nil) end
        if player.vehicle then return end
        player.teleport(warp.surface.find_non_colliding_position('character',warp.position,32,1),warp.surface)
        player.print('Warped you over to: ' .. frame, {r=0.22, g=0.99, b=0.99})
        refresh_gui_player(player)
        return
        end

        if event.element.name == "add_warp_gui" then
        if indexes[player.name].removing == true then indexes[player.name].removing = false end
        if indexes[player.name].creating == false then indexes[player.name].creating = true end
        refresh_gui_player(player)
        return
        end

        if event.element.name == "add_warp_func" then
        local new = menu_frame.wp_name.wp_table.wp_text.text
        if new ~= "" and new ~= "Spawn" and new ~= "Name:" and new ~= "Warp name:" then
            local position = player.position
            if warp_table[new] then player.print("Warp name already exists!", {r=0.22, g=0.99, b=0.99}) return end
            make_warp_point(position,player.surface,player.force,new)
        end
        refresh_gui()
        return
        end
    return false
end

function refresh_gui()
    for _, player in pairs(game.connected_players) do
        local mod_gui = indexes[player.name].mod_gui
        local menu_frame = mod_gui.warp_list_gui
        if (menu_frame) then
            create_gui(player, mod_gui)
        end
    end
end

function refresh_gui_player(player)
    local mod_gui = indexes[player.name].mod_gui
    local menu_frame = mod_gui.warp_list_gui
    if (menu_frame) then
        create_gui(player, mod_gui)
    end
end

local function on_player_created(event)
    if event.player_index == 1 then
        local player = game.players[event.player_index]
        player.force.chart(player.surface, {{player.position.x - 20, player.position.y - 20}, {player.position.x + 20, player.position.y + 20}})
        local tag = player.force.add_chart_tag(player.surface,{
            position={x=0,y=0},
            text='Warp: Spawn',
            icon={type='item',name=warp_item}
        })
        warp_table['Spawn'] = {tag=tag,position={x=0,y=0},surface=player.surface}
    end
end

event.add(defines.events.on_gui_click, on_gui_click)
event.add(defines.events.on_player_created, on_player_created)
event.add(defines.events.on_player_joined_game, on_player_joined_game)