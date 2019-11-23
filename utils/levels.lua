local Event = require "utils.event"
local Global = require "utils.global"
local Schedule = require "utils.schedule"
local particles = require "utils.effects.particles"
local validate_player = require "utils.validate_player"
local extra_mining_speed = 0.60
local extra_bag_slots    = 7
local rock_experience = 50
local players = { }
local rocks = {
  "rock-huge",
  "rock-big",
  "sand-rock-big"
}

Global.register({
  players = players
}, function(global)
  players = global.players
end)


local function get_experience_to_level(level)
  return (50*level^3-6*1^2+17*level-12)/3
end

local function add_experience(player, increase)

  local experience = players[player.name].experience
  local level = players[player.name].level
  local level_label = players[player.name].level_label
  local experience_bar = players[player.name].experience_bar

  if not experience_bar.valid then return end

  local experience_to_level = get_experience_to_level(level + 1)
  players[player.name].experience = players[player.name].experience + increase

  local percent = players[player.name].experience / experience_to_level
  if percent >= 1 then
    players[player.name].level = players[player.name].level + 1
    players[player.name].experience = players[player.name].experience - experience_to_level
    
    experience_to_level = get_experience_to_level(players[player.name].level + 1)
    
    players[player.name].bonus.slots = players[player.name].bonus.slots + extra_bag_slots
    players[player.name].bonus.speed = players[player.name].bonus.speed + extra_mining_speed
    percent = players[player.name].experience / experience_to_level
    if not validate_player(player) then goto continue end
    player.character_mining_speed_modifier = players[player.name].bonus.speed
    player.character_inventory_slots_bonus = players[player.name].bonus.slots
    ::continue::
    
    if players[player.name].level % 5 == 0 then
      for i = 0, 10 do
        for _, p in pairs(game.connected_players) do
          Schedule.add(particles, {p.surface, p.position})
        end
      end
      local total =  players[player.name].level  * 10
      local inserted = player.insert({ name = "coin", count = total})
      if inserted ~= total then
        surface.spill_item_stack(player.position,{ name = "coin" , count = total - inserted }, true)
      end
      game.print({"level.player_level_announcement", player.name, players[player.name].level, total},{r = 0.3, b = 0.3, g = 0.8})
    else
      player.print({"level.level_up", players[player.name].level, extra_mining_speed * 100, extra_bag_slots}, {r = 0.3, b = 0.3, g = 0.8})
      player.insert({ name = "coin", count = players[player.name].level})
    end

  end
  
  experience_bar.value = percent
  level_label.caption = "Level: "..players[player.name].level
end

local function init_levels(event)
  local player = game.players[event.player_index]
  local f = player.gui.top.add({ type = "frame"})
  local table = f.add({ type = "table", column_count = 2 })



  local label = table.add({ type = "label", caption = "Level: 1" })
  local bar   = table.add({ type = "progressbar", value = 0 })
  f.style.maximal_height  = 40


  players[player.name] = {
    level   = 1,
    experience    = 0,
    level_label = label,
    experience_bar    = bar,
    bonus = {
      slots = 0,
      speed = 0
    }
  }
end

local function mined_entity(event)
  local player = game.players[event.player_index]
  local rock_mined
  if not event.entity.valid then return end
  for _, rock in pairs(rocks) do
    if event.entity.name == rock then
      rock_mined = true
    end
  end
  if not rock_mined then return end
  add_experience(player, rock_experience)
end

local function player_respawned(event)
  local player = game.players[event.player_index]
  player.character_mining_speed_modifier = players[player.name].bonus.speed
  player.character_inventory_slots_bonus = players[player.name].bonus.slots
end

Event.register(defines.events.on_player_mined_entity, mined_entity)
Event.register(defines.events.on_player_created, init_levels)
Event.register(defines.events.on_player_respawned, player_respawned)