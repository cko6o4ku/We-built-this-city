local Event = require 'utils.event'
local Gui = require 'features.gui.main'
local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow

local toolbar = {}

--- Add a button to the toolbar, ranks need to be allowed to use these buttons if ranks is preset
-- @usage toolbar.add('foo','Foo','Test',function() game.print('test') end)
-- @tparam string name the name of the button
-- @tparam string caption can be a sprite path or text to show
-- @tparma string tooltip the help to show for the button
-- @tparam function callback the function which is called on_click
-- @treturn table the button object that was made
function toolbar.add(name,caption,tooltip,callback)
    local button = Gui.inputs.add{type='button',name=name,caption=caption,tooltip=tooltip}
    button:on_event(Gui.inputs.events.click,callback)
    Gui._add_data('toolbar',name,button)
    return button
end

--- Draws the toolbar for a certain player
-- @usage toolbar.draw(1)
-- @param player the player to draw the tool bar of
function toolbar.draw(event)
    local player = game.players[event.player_index]
    if not player then return end
	local toolbar_frame = mod(player)
    --toolbar_frame.clear()
    if not Gui._get_data('toolbar') then return end
    for _, button in pairs(Gui._get_data('toolbar')) do
        button:draw(toolbar_frame)
	end
end

Event.add(defines.events.on_player_joined_game,toolbar.draw)

return toolbar