local Event = require 'utils.event'
local Gui = require 'utils.gui.main'
local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow

local toolbar = {}

-- @usage toolbar.add('foo','Foo','Test',function() game.print('test') end)
-- @tparam string name the name of the button
-- @tparam string caption can be a sprite path or text to show
-- @tparma string tooltip the help to show for the button
-- @tparam function callback the function which is called on_click
-- @treturn table the button object that was made
function toolbar.add(name,caption,tooltip,callback)
    local button = Gui.inputs.add{type='sprite-button',name=name,caption=caption,tooltip=tooltip}
    button:on_event(Gui.inputs.events.click,callback)
    Gui.data('toolbar',name,button)
    return button
end

--- Draws the toolbar for a certain player
-- @usage toolbar.draw(1)
-- @param player the player to draw the tool bar of
function toolbar.draw(event)
    local player = game.players[event.player_index]
    if not player then return end
    local frame = mod(player)
    --frame.clear()

    if not Gui.data('toolbar') then return end
    for _, button in pairs(Gui.data('toolbar')) do
        if not player.admin then
        return
        else
            if frame[button.name] then
                frame[button.name].clear()
            else
                button:draw(frame)
            end
        end
	end

   --script.raise_event(Gui.events.on_gui_removal,
   --{
   --    player = player
   --})

end

Event.add(defines.events.on_player_joined_game, toolbar.draw)
--Event.add(defines.events.on_player_promoted, toolbar.draw)
--Event.add(defines.events.on_player_demoted, toolbar.draw)

return toolbar