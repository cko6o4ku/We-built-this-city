local event = require 'utils.event'

function to_kick_or_not_to_kick(event)
    if (game.tick%3600) ~= 0 then return end
    for _,player in pairs(game.connected_players) do
        local afk = #game.connected_players < 3 and 30
        if afk then
            if player.afk_time > afk*3600 then game.kick_player(player,'AFK for too long ('..math.floor(afk)..' minutes)') end
        end
    end
end

event.add(defines.events.on_tick, to_kick_or_not_to_kick)