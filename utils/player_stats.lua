local Event = require "utils.event"
local Global = require "utils.global"
local Schedule = require "utils.schedule"
local ticks_to_time = require "utils.ticks_to_time"
local teleport_player_to_target = require "utils.teleport_player_to_target"
local water_splash = require "utils.effects.water"
local particles = require "utils.effects.particles"

local gui_players_data = {}
local teleport_cooldowns = {}

Global.register({
  gui_players_data = gui_players_data,
  teleport_cooldowns = teleport_cooldowns
  }, function(glob)
    gui_players_data = glob.gui_players_data
    teleport_cooldowns = glob.teleport_cooldowns
end)

local function player_created(event)
  local player = game.players[event.player_index]
  player.gui.top.add({ 
    type = "sprite-button", 
    sprite = "entity/character",
    name = "player_button",
    tooltip = "Player Statistics"
   })
end

local function open_statistics_menu(player)

  if not gui_players_data[player.name] then
    gui_players_data[player.name] = {}
  end

  local data = gui_players_data[player.name]

  if data.frame then
    data.frame.destroy()
    gui_players_data[player.name] = nil
  else
    local frame = player.gui.left.add({ 
      type = "frame",
      direction = "vertical"
    })
    player.opened = frame

    gui_players_data[player.name].frame = frame

    local scroll = frame.add{ type = "scroll-pane" }
    scroll.style.maximal_height = 500

    local connected_players = game.connected_players
    local table = scroll.add{ type = "table", column_count = 3, draw_horizontal_line_after_headers  = true }

    local online_players_table = table.add{ type = "table", column_count = 3 }

    online_players_table.add{ 
      type = "label", 
      caption = #connected_players .." Online" 
    }.style.font_color = { r = 0.3, g = 1, b = 0.3 }
  
    online_players_table.add{ 
      type = "label", 
      caption = " / " 
    }
  
    online_players_table.add{ 
      type = "label", 
      caption = #game.players - #connected_players .. " Offline"
    }.style.font_color = { r = 1, g = 0.3, b = 0.3 }

    table.add{ type = "label", caption = "Online Time" }
    table.add{ type = "label", caption = "Teleport" }
    
    
    for _, connected_player in pairs(connected_players) do
      table.add{ type = "label", caption = connected_player.name }
      table.add{ type = "label", caption = ticks_to_time(connected_player.online_time) } 

      local btn = table.add{ type = "button", caption = "TP", name = connected_player.name }
      btn.style.font_color = { r = 0, g = 0, b  = 0 }
      btn.style.hovered_font_color = { r = 0.15, g = 0.6, b  = 0.45 }
      btn.style.top_padding  = 0
      btn.style.top_padding  = 0
      btn.style.bottom_padding = 0
      if player.name == connected_player.name then
       btn.enabled = false
      end
    end
    table.style.vertical_align  = "center"
    for _, element in pairs(table.children) do
      element.style.minimal_width = 150
    end
  end
end

local function gui_click(event)
  local player = game.players[event.player_index]
  if not event.element.valid then return end
  local name = event.element.name
  
  if name == "player_button" then
    open_statistics_menu(player)
    return
  end
  
  if game.players[name] then

    if not player.valid then return end
    if not player.character then return end
    if not game.players[name].valid then return end
    if not game.players[name].character then return end

    if not teleport_cooldowns[player.name] then
      teleport_cooldowns[player.name] = event.tick
    end

    if teleport_cooldowns[player.name] <= event.tick then

      teleport_player_to_target(player, game.players[name])
      teleport_cooldowns[player.name] = event.tick + 60 * 60 * 30
    else
      local cooldown = ticks_to_time(teleport_cooldowns[player.name] - event.tick)
      player.print(string.format("Teleport on cooldown, you can use this again in%s", cooldown))
    end
  end
end

local function gui_closed(event)
  local player = game.players[event.player_index]
  local type = event.gui_type
  
  if type == defines.gui_type.custom then
    local data = gui_players_data[player.name]
    if not data then return end
    if data["frame"] then
      data.frame.destroy()
      gui_players_data[player.name] = nil
    end
  end
end

Event.register(defines.events.on_player_created, player_created)
Event.register(defines.events.on_gui_click, gui_click)
Event.register(defines.events.on_gui_closed, gui_closed)