local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow
local OE = require 'features.modules.oarc_enemies.oarc_enemies'
local Utils = require 'map_gen.mps_0_17.lib.oarc_gui_utils'
local OE_Table = require 'features.modules.oarc_enemies.table'

local Public = {}

function Public.OarcEnemiesCreateGui(event)
    local player = game.players[event.player_index]
    if mod(player).oarc_enemies == nil then
        mod(player).add{name="oarc_enemies", type="button", caption="OE", style=m_gui.button_style}
    end
end

local function ExpandOarcEnemiesGui(player)
    local gd = OE_Table.get_table()
    local frame = mod(player)["oe-panel"]
    if (frame) then
        frame.destroy()
    else
        local frame = mod(player).add{type="frame", name="oe-panel", caption="Oarc's Enemies:", direction = "vertical"}

        local oe_info="General Info:" .. "\n" ..
                        -- "Units: " .. #gd.units .. "\n" ..
                        "Attacks: " .. #gd.attacks .. "\n" ..
                        -- "Labs: " .. #gd.science_labs[player.name] .. "\n" ..
                        "Next Player Attack: " .. gd.player_timers[player.name].next_wave_player .. "\n" ..
                        "Next Building Attack: " .. gd.player_timers[player.name].next_wave_buildings
        Utils.AddLabel(frame, "oe_info", oe_info, Utils.my_longer_label_style)
    end
end


return Public