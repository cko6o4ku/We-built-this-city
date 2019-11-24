-- oarc_enemis_gui.lua
-- July 2019
-- GUI for my enemy mod

local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow
local OE = require 'features.modules.oarc_enemies.oarc_enemies'
local Utils = require 'map_gen.mps_0_17.lib.oarc_gui_utils'

local Public = {}

function Public.OarcEnemiesCreateGui(event)
    local player = game.players[event.player_index]
    if mod(player).oarc_enemies == nil then
        mod(player).add{name="oarc_enemies", type="button", caption="OE", style=m_gui.button_style}
    end
end

local function ExpandOarcEnemiesGui(player)
    local frame = mod(player)["oe-panel"]
    if (frame) then
        frame.destroy()
    else
        local frame = mod(player).add{type="frame", name="oe-panel", caption="Oarc's Enemies:", direction = "vertical"}

        frame.add{type="button", caption="Player Attack", name="oe_attack_player"}
        frame.add{type="button", caption="General Attack", name="oe_attack_any"}
        frame.add{type="button", caption="Science Labs Attack", name="oe_attack_labs"}
        frame.add{type="button", caption="Furnace Attack", name="oe_attack_furnace"}
        frame.add{type="button", caption="Mining Attack", name="oe_attack_mining"}
        frame.add{type="button", caption="Turret Attack", name="oe_attack_turret"}

        local oe_info="General Info:" .. "\n" ..
                        -- "Units: " .. #global.oe.units .. "\n" ..
                        "Attacks: " .. #global.oe.attacks .. "\n" ..
                        -- "Labs: " .. #global.oe.science_labs[player.name] .. "\n" ..
                        "Next Player Attack: " .. global.oe.player_timers[player.name].character .. "\n" ..
                        "Next Building Attack: " .. global.oe.player_timers[player.name].generic
        Utils.AddLabel(frame, "oe_info", oe_info, Utils.my_longer_label_style)
    end
end

function Public.OarcEnemiesGuiClick(event)
    if not (event and event.element and event.element.valid) then return end
    local player = game.players[event.element.player_index]
    local name = event.element.name

    if (name == "oarc_enemies") then
        ExpandOarcEnemiesGui(player)
    end

    if (name == "oe_attack_player") then
        OE.OarcEnemiesPlayerAttackCharacter(player.name)
    end

    if (name == "oe_attack_any") then
        OE.OarcEnemiesBuildingAttack(player.name, {"ammo-turret",
                                                "electric-turret",
                                                "fluid-turret",
                                                "artillery-turret",
                                                "mining-drill",
                                                "furnace",
                                                "reactor",
                                                "assembling-machine",
                                                "generator"})
    end

    if (name == "oe_attack_labs") then
        OE.OarcEnemiesScienceLabAttack(player.force.name)
    end

    if (name == "oe_attack_furnace") then
        OE.OarcEnemiesBuildingAttack(player.name, "furnace")
    end

    if (name == "oe_attack_mining") then
        OE.OarcEnemiesBuildingAttack(player.name, "mining-drill")
    end

    if (name == "oe_attack_turret") then
        OE.OarcEnemiesBuildingAttack(player.name, {"ammo-turret",
                                                "electric-turret",
                                                "fluid-turret",
                                                "artillery-turret"})
    end
end

return Public