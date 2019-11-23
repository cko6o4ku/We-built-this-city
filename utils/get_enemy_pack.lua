
local enemies = {
  "small-biter",
  "medium-biter",
  "small-spitter",
  "small-worm-turret",
  "medium-spitter",
  "medium-worm-turret",
  "big-biter",
  "big-spitter",
  "big-worm-turret",
  "behemoth-biter",
  "behemoth-spitter"
}

local function get_enemy_pack(evolution, min, max)
  local count = math.random(min, max)
  -- evolution unlock
  -- 0 small biter
  -- 0.21 medium biter
  -- 0.26 small spitter
  -- 0.3 small worm turret
  -- 0.41 medium spitter
  -- 0.5 medium worm turret
  -- 0.51 big biter 
  -- 0,62 big spitter
  -- 0.85 big worm turret
  -- 0.9 behemoth biter
  -- 0.93 behemoth spitter
  local evolution_unlock_rates = { 0, 0.21, 0.26, 0.3, 0.41, 0.5, 0.51, 0.62, 0.85, 0.9, 0.93 }
  local index
  for i = #evolution_unlock_rates, 1, -1 do
    if evolution >= evolution_unlock_rates[i] then
      index = i
      break
    end
  end

  
  local temp = {}
  for _ = 1, count do
    local enemy = enemies[math.random(1, index)]
    table.insert(temp, enemy)
  end

  return temp
end


return get_enemy_pack