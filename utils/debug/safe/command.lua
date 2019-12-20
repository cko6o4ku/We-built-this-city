local DebugView = require 'utils.debug.safe.main_view'
local Roles = require 'utils.role.table'



commands.add_command(
    'debug',
    'Opens the debugger',
    function(_)
        local player = game.player
        local p
        if player then
            p = player.print
            if not Roles.get_role(player):allowed('debugger') then
                p('Only admins can use this command.')
                return
            end
        else
            p = player.print
        end
        DebugView.open_dubug(player)
    end
)