local Event = require "utils.event"
local Global = require "utils.global"
local Schedule = require "utils.schedule"
local distance = require "utils.distance"
local validate_player = require "utils.validate_player"
local get_enemy_pack = require "utils.get_enemy_pack"

local in_darkness_warned = {}
local spawn_radius = 10

Global.register({ 
  in_darkness_warned = in_darkness_warned
}, function(global)
  in_darkness_warned = global.in_darkness_warned
end)


local function check_players_in_darkness()

  for _, player in pairs(game.connected_players) do
    if not validate_player(player) then goto do_nothing end
    if player.surface.name ~= "cave" then goto do_nothing end
    local dist = distance(player.position, {0,0})
    if dist < spawn_radius * 2 then 
      goto do_nothing 
    end

    if not in_darkness_warned[player.name] then
      player.print({"warnings.first_time_in_darkness"}, {r = 1, g = 0, b = 0})
      in_darkness_warned[player.name] = true
      goto do_nothing
    end

    local surface = player.surface
    -- assume they are in darkenss?
    local darkness = true
  
    local lamps = surface.find_entities_filtered({ 
      position = player.position, 
      name = "small-lamp", 
      radius = 15
    })
  
    if #lamps == 0 then 
      darkness = true
    else
      for _, lamp in pairs(lamps) do
        if lamp.energy > 0 then
          darkness = false
        end
      end
    end


    -- do sonmething
    if darkness and dist > spawn_radius * 2 + 1 then
     local enemies = get_enemy_pack(game.forces.enemy.evolution_factor, 4, 15)
     for _, enemy in pairs(enemies) do
        local pos = { player.position.x + math.random(-5, 5), player.position.y + math.random(-5, 5) }
        local safe = surface.find_non_colliding_position(enemy, pos, 5, 1)
        if safe then
          surface.create_entity({ name = enemy, position = safe })
        else
          surface.create_entity({ name = enemy, position = pos })
        end
      end
    end 
  end

  ::do_nothing::
end


Event.on_nth_tick(60 * 10, check_players_in_darkness)