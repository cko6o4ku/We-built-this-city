local Event = require 'utils.event'
local Server = require 'utils.server'
local session = require 'utils.session_data'
local Color = require 'utils.color_presets'
local Roles = require 'utils.role.main'
local font = "default-game"

local brain = {
    [1] = {"Our Discord server is at: discord.io/wbtc"},
    [2] = {"Need an admin? Type @Mods in game chat to notify moderators,", "or put a message in the discord help channel."}
}

local links = {
    ["admin"] = brain[2],
    ["administrator"] = brain[2],
    ["discord"] = brain[1],
    ["greifer"] = brain[2],
    ["grief"] = brain[2],
    ["griefer"] = brain[2],
    ["griefing"] = brain[2],
    ["mod"] = brain[2],
    ["ban"] = brain[2],
    ["mods"] = brain[2],
    ["moderator"] = brain[2],
    ["stealing"] = brain[2],
    ["stole"] = brain[2],
    ["troll"] = brain[2],
    ["trolling"] = brain[2],
}

local function on_player_created(event)
    local player = game.players[event.player_index]
    local trusted = session.get_trusted_table()
    --player.print("[font=" .. font .. "]" .. "Join our sweet discord >> discord.io/wbtc" .. "[/font]", Color.success)
    if player.admin then
        trusted[player.name] = true
    end
end

commands.add_command(
    'trust',
    'Promotes a player to trusted!',
    function(cmd)
        local trusted = session.get_trusted_table()
        local server = 'Server'
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not (player.admin or trusted[player.name]) then
                    p("You're not admin nor trusted!", Color.fail)
                    return
                end
            else
                p = log
            end

            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if not target_player then return end
            if target_player then
                --if target_player.name == player.name then game.print("You can't trust yourself ;)", Color.info) return end
                if trusted[target_player.name] == true then game.print(target_player.name .. " is already trusted!") return end
                local target_role = Roles.get_role(target_player)
                local source_role = Roles.get_role(player)
                if source_role.power <= target_role.power then
                    Roles.give_role(target_player, 'Casual')
                end
                trusted[target_player.name] = true
                game.print(target_player.name .. " is now a trusted player.", Color.success)
                for _, a in pairs(game.connected_players) do
                    if a.admin == true and a.name ~= player.name then
                        a.print("[INFO]: " .. player.name .. " trusted " .. target_player.name, Color.info)
                        Server.to_admin_embed(table.concat{'[Info] ', player.name, ' has trusted ', target_player.name, '.'})
                    end
                end
            end
        else
            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                if trusted[target_player.name] == true then log(target_player.name .. " is already trusted!") return end
                trusted[target_player.name] = true
                game.print(target_player.name .. " is now a trusted player.", Color.success)
                Server.to_admin_embed(table.concat{'[Info] ', server, ' has trusted ', target_player.name, '.'})
            end
        end
    end
)

commands.add_command(
    'untrust',
    'Demotes a player from trusted!',
    function(cmd)
        local trusted = session.get_trusted_table()
        local server = 'server'
        local player = game.player
        local p

        if player then
            if player ~= nil then
                p = player.print
                if not (player.admin or trusted[player.name]) then
                    p("You're not admin nor trusted!", Color.fail)
                    return
                end
            else
                p = log
            end

            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if not target_player then return end
            if target_player then
                if target_player.name == player.name then game.print("You can't untrust yourself ;)", Color.info) return end
                if trusted[target_player.name] == false then game.print(target_player.name .. " is already untrusted!") return end
                local target_role = Roles.get_role(target_player)
                local source_role = Roles.get_role(player)
                if source_role.power <= target_role.power then
                    Roles.give_role(target_player, 'Rookie')
                end
                trusted[target_player.name] = false
                game.print(target_player.name .. " is now untrusted.", Color.success)
                for _, a in pairs(game.connected_players) do
                    if a.admin == true and a.name ~= player.name then
                        a.print("[ADMIN]: " .. player.name .. " untrusted " .. target_player.name, Color.info)
                        Server.to_admin_embed(table.concat{'[Info] ', player.name, ' has untrusted ', target_player.name, '.'})
                    end
                end
            end
        else
            if cmd.parameter == nil then return end
            local target_player = game.players[cmd.parameter]
            if target_player then
                if trusted[target_player.name] == false then log(target_player.name .. " is already untrusted!") return end
                trusted[target_player.name] = false
                game.print(target_player.name .. " is now untrusted.", Color.success)
                Server.to_admin_embed(table.concat{'[Info] ', server,  ' has untrusted ', target_player.name, '.'})
            end
        end
    end
)

local function process_bot_answers(event)
    local message = event.message
    message = string.lower(message)
    if links[message] then
        for _, bot_answer in pairs(links[message]) do
            game.print("[font=" .. font .. "]" .. bot_answer .. "[/font]", Color.info)
        end
        return
    end
end

local function on_console_chat(event)
    if not event.player_index then return end
    process_bot_answers(event)
end

--share vision of silent-commands with other admins
local function on_console_command(event)
    local cmd = event.command
    if not (cmd == "silent-command" or cmd == "sc") then return end
    if not event.player_index then return end
    local player = game.players[event.player_index]
    Server.to_admin_embed(table.concat{'[Info] ', player.name, ' ran command: ', event.parameters, ' at game.tick: ', game.tick, '.'})
end

Event.add(defines.events.on_player_created, on_player_created)
--Event.add(defines.events.on_console_chat, on_console_chat)
Event.add(defines.events.on_console_command, on_console_command)
