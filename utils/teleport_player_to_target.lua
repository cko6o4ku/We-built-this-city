local validate_player = require "utils.validate_player"
local function teleport_player_to_target(player, target)
  if not validate_player(player) then return end
  if not validate_player(target) then return end
  local safe_position = target.surface.find_non_colliding_position("character", target.position, 10, 0.1)
  if not safe_position then return end
  player.teleport(safe_position, target.surface)
end


return teleport_player_to_target