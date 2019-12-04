local Event = require 'utils.event'
local Gui = require 'features.gui.test.core'

local test_gui = {}

local gui_test_close = Gui.inputs.add{
    name='gui-test-close',
    type='button',
    caption='Close Test Gui'
}:on_event('click',function(event) event.element.parent.destroy() end)


local caption_test = Gui.inputs.add{
    name='text-button',
    type='button',
    caption='Test'
}:on_event('click',function(event) game.print('test') end)

local sprite_test = Gui.inputs.add{
    name='sprite-button',
    type='button',
    sprite='item/lab'
}:on_event('click',function(event) spwn_ctrls() end)

local input_test = Gui.inputs.add_button('test-inputs','Try RMB','alt,ctrl,shift and mouse buttons',{
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.alt end,
        function(player,element) player_return('Left: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.ctrl end,
        function(player,element) player_return('Left: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.left and keys.shift end,
        function(player,element) player_return('Left: Shift',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.alt end,
        function(player,element) player_return('Right: Alt',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.ctrl end,
        function(player,element) player_return('Right: Ctrl',nil,player) end
    },
    {
        function(player,mouse,keys) return mouse == defines.mouse_button_type.right and keys.shift end,
        function(player,element) player_return('Right: Shift',nil,player) end
    }
}):on_event('error',function(err) game.print('this is error handliling') end)

local elem_test = Gui.inputs.add_elem_button('test-elem','item','Testing Elems',function(player,element,elem)
    return elem.type..' '..elem.value,nil,player
end)

local check_test_1 = Gui.inputs.add_checkbox('test-check1',false,'Cheat Mode',function(player,parent) 
    return game.players[parent.player_index].cheat_mode 
end,function(player,element)
    player.cheat_mode = true
end,function(player,element)
    player.cheat_mode = false
end)
local check_test_2 = Gui.inputs.add_checkbox('test-check2',false,'Run',function(player,parent) 
    return game.players[parent.player_index].character_running_speed_modifier 
end,function(player,element) 
    player.character_running_speed_modifier = 1 
end,function(player,element)
    player.character_running_speed_modifier = 0
end)

local check_test_3 = Gui.inputs.add_checkbox('test-check3',false,'Mine',function(player,parent) 
    return game.players[parent.player_index].character_mining_speed_modifier 
end,function(player,element) 
    player.character_mining_speed_modifier = 2 
end,function(player,element)
    player.character_mining_speed_modifier = 0
end)

local check_test_4 = Gui.inputs.add_checkbox('test-check4',false,'Craft',function(player,parent) 
    return game.players[parent.player_index].character_crafting_speed_modifier 
end,function(player,element) 
    player.character_crafting_speed_modifier = 5 
end,function(player,element)
    player.character_crafting_speed_modifier = 0
end)

Gui.left.add{
    name='test-left',
    caption='FS',
    tooltip='just testing',
    draw=function(frame)
    check_test_1:draw(frame)
	check_test_2:draw(frame)
	check_test_3:draw(frame)
	check_test_4:draw(frame)
    end,
    can_open=function(player) return true end
}



return test_gui