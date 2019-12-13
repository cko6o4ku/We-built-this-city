-- control stages
require 'utils.data_stages'
_LIFECYCLE = _STAGE.control -- Control stage
_DEBUG = true
_DUMP_ENV = false

-- other stuff
local Event = require 'utils.event'
require 'utils.server'
require 'utils.server_commands'
require 'utils.utils'
require 'utils.table'
require 'utils.color_data'
require 'utils.session_data'
require 'utils.player_modifiers'
require 'utils.surface'
require 'utils.rank.main'
local Rank = require 'utils.rank.presets'
--require 'utils.rank.add_ranks'
Rank._auto_edit_ranks()



require 'utils.gui.main'
require 'utils.gui.player_list'
require 'utils.gui.admin'
require 'utils.gui.group'
require 'utils.gui.poll'
require 'utils.gui.score'
require 'utils.gui.config'
require 'utils.gui.game_settings'
--require 'utils.gui.tag'
require 'utils.gui.warp_system'
require 'features.functions.chatbot'
require 'features.functions.antigrief'
require 'features.modules.corpse_markers'
require 'features.modules.floaty_chat'
require 'features.modules.autohotbar'
require 'features.modules.autostash'
require 'features.commands.repair'
--require 'features.commands.bonus'
require 'features.commands.misc'

require 'features.modules.rpg'

-- load from config/map
require 'config'

-- lua profiler by boodals
if _DEBUG then
	require 'utils.profiler'
end

if _DEBUG then
	function raw(string)
		return game.print(serpent.block(string))
	end
end

if _DUMP_ENV then
    require 'utils.dump_env'
end
if _DEBUG then
    require 'utils.debug.command'
end

local function on_player_created(event)
	local player = game.players[event.player_index]
	player.gui.top.style = 'slot_table_spacing_horizontal_flow'
	player.gui.left.style = 'slot_table_spacing_vertical_flow'
end

local function on_init()
	game.forces.player.research_queue_enabled = true
end

local loaded = _G.package.loaded
function require(path)
    return loaded[path] or error('Can only require files at runtime that have been required in the control stage.', 2)
end


Event.on_init(on_init)
Event.add(defines.events.on_player_created, on_player_created)
