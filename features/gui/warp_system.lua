local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow
local Gui = require 'utils.gui'
local Event = require 'utils.event'
local Global = require 'utils.global'
local Surface = require 'utils.surface'
local Tabs = require 'features.gui.main'
local Color = require 'utils.color_presets'
local Session = require 'utils.session_data'

local warp_entities = {
    {'small-lamp',-3,-2},{'small-lamp',-3,2},{'small-lamp',3,-2},{'small-lamp',3,2},
    {'small-lamp',-2,-3},{'small-lamp',2,-3},{'small-lamp',-2,3},{'small-lamp',2,3},
    {'small-electric-pole',-3,-3},{'small-electric-pole',3,3},{'small-electric-pole',-3,3},{'small-electric-pole',3,-3}
}
local warp_tiles = {
    {-3,-2},{-3,-1},{-3,0},{-3,1},{-3,2},{3,-2},{3,-1},{3,0},{3,1},{3,2},
    {-2,-3},{-1,-3},{0,-3},{1,-3},{2,-3},{-2,3},{-1,3},{0,3},{1,3},{2,3}
}

local radius = 4
local warp_tile = 'tutorial-grid'
local warp_item = 'discharge-defense-equipment'
local global_offset = {x=0,y=0}

local main_button_name = Gui.uid_name()
local main_frame_name = Gui.uid_name()
local create_warp_button_name = Gui.uid_name()
local go_to_warp_name = Gui.uid_name()
local confirmed_button_name = Gui.uid_name()
local create_warp_func_name = Gui.uid_name()
local remove_warp_button_name = Gui.uid_name()
local close_main_frame_name = Gui.uid_name()

local warp_table = {}
local misc_table = {}
local player_table = {}

Global.register({
    warp_table=warp_table,
    misc_table=misc_table,
    player_table=player_table
},function(t)
    warp_table = t.warp_table
    player_table = t.player_table
end)

local Public = {}

function Public.remove_warp_point(name)
    local warp = warp_table[name]
    if not warp then return end
    local base_tile = warp.old_tile
    local surface =  warp.surface
    local offset = warp.position
    local tiles = {}
    if name == 'Spawn' then return end
    for x = -radius-2, radius+2 do
        for y = -radius-2, radius+2 do
            if x^2+y^2 < (radius+1)^2 then
                table.insert(tiles,{name=base_tile,position={x+offset.x,y+offset.y}})
                local entities = surface.find_entities_filtered{area={{x+offset.x-1,y+offset.y-1},{x+offset.x,y+offset.y}}}
                for _,entity in pairs(entities) do if entity.name ~= 'character' then entity.destroy() end end
                --or entity.name ~= 'player' or entity.name ~= 'bob-character-fighter' or entity.name ~= 'bob-character-miner' or entity.name ~= 'bob-character-builder'
            end
        end
    end
    if warp.old_tile then surface.set_tiles(tiles) end
    if warp.tag then warp.tag.destroy() end
    warp_table[name] = nil
end

function Public.make_warp_point(position,surface,force,name)
    local warp = warp_table[name]
    if warp then return end
    local offset = {x=math.floor(position.x),y=math.floor(position.y)}
    local old_tile = surface.get_tile(offset).name
    local base_tiles = {}
    local tiles = {}
    -- player_table makes the base template to make the warp point
    for x = -radius-2, radius+2 do
        for y = -radius-2, radius+2 do
            if x^2+y^2 < radius^2 then
                table.insert(base_tiles,{name=warp_tile,position={x+offset.x,y+offset.y}})
            end
        end
    end
    surface.set_tiles(base_tiles)
    -- player_table adds the patterns and entities
    for _,p in pairs(warp_tiles) do
        table.insert(tiles,{name=warp_tile,position={p[1]+offset.x+global_offset.x,p[2]+offset.y+global_offset.y}})
    end
    surface.set_tiles(tiles)
    for _,e in pairs(warp_entities) do
        local entity = surface.create_entity{name=e[1],position={e[2]+offset.x+global_offset.x,e[3]+offset.y+global_offset.y},force='neutral'}
        entity.destructible = false; entity.health = 0; entity.minable = false; entity.rotatable = false
    end
    local tag = force.add_chart_tag(surface,{
        position={offset.x+0.5,offset.y+0.5},
        text='Warp: '..name,
        icon={type='item',name=warp_item}
    })
    warp_table[name] = {tag=tag,position=tag.position,surface=surface,old_tile=old_tile}
end

function Public.create_warp_button(player)
    local button = mod(player).warp_button
    if button then
        button.destroy()
    end
    local b = mod(player).add{
    type = "sprite-button",
    sprite = "item/discharge-defense-equipment",
    name = main_button_name,
    tooltip = "Warp to places!"
    }
    b.style.font_color = Color.success
    b.style.font = "heading-1"
    b.style.minimal_height = 38
    b.style.minimal_width = 38
    b.style.top_padding = 2
    b.style.left_padding = 4
    b.style.right_padding = 4
    b.style.bottom_padding = 2
end

local function draw_main_frame(player, left)
    local trusted = Session.get_trusted_table()
    --local mod_gui = player_table[player.index].mod_gui

    local subhead = left.add{type = "frame", name = main_frame_name, caption = "Warps", direction = "vertical", style = "changelog_subheader_frame"}
    subhead.style.left_margin = 10
    subhead.style.right_margin = 10
    subhead.style.top_margin = 4
    subhead.style.bottom_margin = 4
    subhead.style.padding = 5
    subhead.style.horizontally_stretchable = true

    local tbl = subhead.add{type = "table", column_count = 10}
    local l = tbl.add{type = "label"}
    l.style.font_color = Color.success
    l.style.font = "default-listbox"

    local _flows1 = tbl.add{type = 'flow'}
    _flows1.style.minimal_width = 150
    _flows1.style.horizontally_stretchable = true

    local _flows2 = tbl.add{type = 'flow'}

    local ts = subhead.add{type = "table", column_count = 1}

    local f = ts.add{type = "frame", column_count = 2}

    local t = f.add{type = "table", column_count = 10}

    local warp_list = t.add{type = 'scroll-pane', direction = 'vertical', vertical_scroll_policy = 'auto', horizontal_scroll_policy = 'never'}
    warp_list.vertical_scroll_policy = 'auto'
    warp_list.style.maximal_height = 200

    local table = warp_list.add{type = 'table', column_count = 3}
    for name,warp in pairs(warp_table) do
        if not warp.tag or not warp.tag then
            for k, v in pairs (game.forces) do
                v.add_chart_tag(warp.surface,{
                    position=warp.position,
                    text='Warp: '..name,
                    icon={type='item',name=warp_item}
                })
            end
        end
        local lb = table.add{type='label', caption=name, style='caption_label'}

        local _flows3 = table.add{type='flow'}
        _flows3.style.minimal_width = 105

        local _flows = table.add{type='flow', name=name}
        local btn = _flows.add{type = "sprite-button", name = go_to_warp_name, tooltip = "Goto!", sprite='utility/export_slot'}
        btn.style.height = 20
        btn.style.width = 20
        if _flows.name ~= "Spawn" then
            btn = _flows.add{type = "sprite-button", name = remove_warp_button_name, tooltip = "Remove!", sprite='utility/remove'}
            btn.style.height = 20
            btn.style.width = 20
        else
            local btn = _flows.add{type = "sprite-button", name = remove_warp_button_name, enabled = "false", tooltip = "Disabled.", sprite='utility/remove'}
            btn.style.height = 20
            btn.style.width = 20
        end
        if player_table[player.index].removing == true then
            if _flows.name == misc_table["frame"] then
                if player.admin or trusted[player.name] then
                    local btn = _flows.add{
                    type = "sprite-button",
                    name = confirmed_button_name,
                    tooltip = "Are you sure?",
                    sprite='utility/confirm_slot'
                    }
                    btn.style.height = 20
                    btn.style.width = 20
                else
                    local btn = _flows.add{
                    type = "sprite-button",
                    name = confirmed_button_name,
                    enabled = "false",
                    tooltip = "Sorry, you need to be trusted to remove warps..",
                    sprite='utility/set_bar_slot'
                    }
                    btn.style.height = 20
                    btn.style.width = 20
                end
                player_table[player.index].removing = false
            end
        end

        if player_table[player.index].creating == true then
            if player.admin or trusted[player.name] then
                local position = player.position
                local posx = position.x
                local posy = position.y
                local dist2 = 100^2

                for name,warp_id in pairs(warp_table) do
                    local pos = warp_id.position
                    if (posx-pos.x)^2+(posy-pos.y)^2 < dist2 then
                        player.print('Too close to another warp: ' .. name , Color.fail)
                        player_table[player.index].creating = false
                        Public.refresh_gui()
                        return
                    end
                end

                local frame = subhead.add{
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
                name = create_warp_func_name,
                tooltip = "Creates a new warp point.",
                sprite='utility/downloaded'
                }
                btn.style.height = 20
                btn.style.width = 20

                player_table[player.index].creating = false
            end
        end
    end
    local bottom_flow = subhead.add {type = 'flow', direction = 'horizontal'}

    local left_flow = bottom_flow.add {type = 'flow'}
    left_flow.style.horizontal_align = 'left'
    left_flow.style.horizontally_stretchable = true

    local close_button = left_flow.add {type = 'button', name = close_main_frame_name, caption = 'Close'}
    Tabs.apply_button_style(close_button)

    local button_flow = left_flow.add{type = "flow"}
    button_flow.style.horizontal_align = "right"
    button_flow.style.horizontally_stretchable = true

    if trusted[player.name] or player.admin then
        local button =
            button_flow.add {type = 'button', name = create_warp_button_name, caption = 'Create Warp'}
        Tabs.apply_button_style(button)
    else
        local button =
            button_flow.add {type = 'button', name = create_warp_button_name, caption = 'Create Warp.', enabled = false, tooltip = 'Sorry, you need to be trusted to create warps..'}
        Tabs.apply_button_style(button)
    end
end

function Public.toggle(player)
    local left = player_table[player.index].left
    local main_frame = left[main_frame_name]

    if main_frame then
        Public.close_gui_player(player)
    else
        Tabs.panel_clear_left_gui(player)
        draw_main_frame(player, left)
    end
end

function Public.refresh_gui_player(player)
    local left = player_table[player.index].left
    local main_frame = left[main_frame_name]
    if main_frame then
        Public.close_gui_player(player)
        draw_main_frame(player, left)
    end
end

function Public.close_gui_player(player)
    local left = player_table[player.index].left
    local menu_frame = left[main_frame_name]
    if (menu_frame) then
        menu_frame.destroy()
    end
end

function Public.refresh_gui()
    for _, player in pairs(game.connected_players) do
        local left = player_table[player.index].left
        local menu_frame = left[main_frame_name]
        if (menu_frame) then
            Public.close_gui_player(player)
            draw_main_frame(player, left)
        end
    end
end

local function on_player_joined_game(event)
    local player = game.players[event.player_index]
    if not player_table[player.index] then
        player_table[player.index] = {
        creating=false,
        removing=false,
        left=player.gui.left,
        spam = 200
        }
    end
    Public.create_warp_button(player)
end

local function on_gui_click(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local left = player_table[player.index].left
    local frame = event.element.parent.name
    misc_table["frame"] = frame
    local warp = warp_table[frame]
    local elem = event.element
    local name = elem.name

        if name == close_main_frame_name then
            Public.toggle(player)
        end

        if name == main_button_name then
            if player_table[player.index].spam > game.tick then
                player.print("Please wait " .. math.ceil((player_table[player.index].spam - game.tick)/60) .. " seconds before trying to warp or add warps again.", Color.warning)
                return
            end
            Public.toggle(player)
            if player_table[player.index].removing == true then
                player_table[player.index].removing = false
            end
            return
        end
        if name == remove_warp_button_name then
            if not player_table[player.index].removing == true then player_table[player.index].removing = true end
            Public.refresh_gui_player(player)
            return
        end

        if name == confirmed_button_name then
        Public.remove_warp_point(frame)
        game.print(player.name .. " removed warp: " .. frame, Color.warning)
        if player_table[player.index].removing == true then
            player_table[player.index].removing = false
        end
        Public.refresh_gui()
        return
        end

        if name == go_to_warp_name then
        if not player_table[player.index].removing == true then player_table[player.index].removing = false end
        Public.refresh_gui()
        local position = player.position
        if (warp.position.x - position.x)^2 + (warp.position.y - position.y)^2 < 1024 then
        player.print('Destination is source warp: ' .. frame, Color.fail)
        return end
        if player.vehicle then player.vehicle.set_driver(nil) end
        if player.vehicle then player.vehicle.set_passenger(nil) end
        if player.vehicle then return end
        player.teleport(warp.surface.find_non_colliding_position('character',warp.position,32,1),warp.surface)
        player.print('Warped you over to: ' .. frame, Color.success)
        player_table[player.index].spam = game.tick + 900
        Public.close_gui_player(player)
        return
        end

        if name == create_warp_button_name then
        if player_table[player.index].removing == true then player_table[player.index].removing = false end
        if player_table[player.index].creating == false then player_table[player.index].creating = true end
        Public.refresh_gui_player(player)
        return
        end

        if name == create_warp_func_name then
        local new = left[main_frame_name].wp_name.wp_table.wp_text.text
        if new ~= "" and new ~= "Spawn" and new ~= "Name:" and new ~= "Warp name:" then
            local position = player.position
            if warp_table[new] then player.print("Warp name already exists!", Color.fail) return end
            Public.make_warp_point(position,player.surface,player.force,new)
            player_table[player.index].spam = game.tick + 900
            game.print(player.name .. " created warp: " .. new, Color.success)
        end
        Public.refresh_gui()
        return
        end
    return false
end

function Public.make_tag(name, pos)
    local get_surface = Surface.get_surface_name()
    local surface = game.surfaces[get_surface]
    local data = {}
    if data.forces then data.forces = nil end
    for k, v in pairs (game.forces) do
        data.forces = v
    end
    local v = data.forces.add_chart_tag(surface,{
         position=pos,
         text='Warp: '..name,
         icon={type='item',name=warp_item}
     })
    warp_table[name] = {tag=v,position=pos,surface=surface}
    return data
end

Event.add(defines.events.on_tick, function()
    if game.tick == 150 then
    Public.make_tag("Spawn", {x=0,y=0})
    end
end)


Event.add(defines.events.on_gui_click, on_gui_click)
Event.add(defines.events.on_player_joined_game, on_player_joined_game)


return Public