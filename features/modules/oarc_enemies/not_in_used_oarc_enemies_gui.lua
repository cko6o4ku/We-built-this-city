local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow
local Event = require 'utils.event'
local OE_Table = require 'features.modules.oarc_enemies.table'

local Public = {}

function Public.OarcEnemiesCreateGui(event)
    local player = game.players[event.player_index]
    if mod(player).oarc_enemies == nil then
        mod(player).add{name="oarc_enemies", type="button", caption="OE", style=m_gui.button_style}
    end
end

local function create_wave_gui(player)
    local tbl = OE_Table.get_table()
    if mod(player).wave then mod(player).wave.destroy() end
    local frame = mod(player).add({ type = "frame", name = "wave"})
    frame.style.maximal_height = 38

    local wave_number = 0
    if tbl.player_wave[player.name].wave_number then wave_number = tbl.player_wave[player.name].wave_number end

    if not tbl.player_wave[player.name].grace then
        local next_level_progress = math.floor(((tbl.p_time[player.name].next_wave_player - (player.online_time % tbl.p_time[player.name].next_wave_player)) / 60) / 60)
        local label = frame.add({ type = "label", caption = "Wave " .. wave_number .. " in: " .. next_level_progress .. " minutes.", tooltip="Man your defenses!" })
        label.style.font_color = {r=0.88, g=0.88, b=0.88}
        label.style.font = "default-listbox"
        label.style.left_padding = 4
        label.style.right_padding = 4
        label.style.minimal_width = 68
        label.style.font_color = {r=0.33, g=0.66, b=0.9}
        --label.style.width = 55
        game.print(serpent.block(next_level_progress))
    else
        local time_remaining = math.floor(((tbl.p_time[player.name].next_wave_player - (player.online_time % tbl.p_time[player.name].next_wave_player)) / 60) / 60)
        if time_remaining <= 0 then
            tbl.player_wave[player.name].grace = nil
            return
        end

        local label = frame.add({ type = "label", caption = "Wave starts in: " .. time_remaining .. " minutes.", tooltip="Your own personal biter wave battle."})
        label.style.font_color = {r=0.88, g=0.88, b=0.88}
        label.style.font = "default-listbox"
        label.style.left_padding = 4
        label.style.right_padding = 4
        label.style.font_color = {r=0.33, g=0.66, b=0.9}
    end
end

Event.add(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    if not player then
        return
    end
    create_wave_gui(player)
end)

Event.add(defines.events.on_tick, function()
    for _, player in pairs(game.connected_players) do
        create_wave_gui(player)
    end
end)

return Public