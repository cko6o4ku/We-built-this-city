
local event = require 'utils.event'
local Global = require 'utils.global'
local m_gui = require "mod-gui"
local mod = m_gui.get_frame_flow

panel_tabs = {}
local disabled_tabs = {}
local icons = {
	"entity/small-biter", "entity/character", "entity/medium-biter", "entity/character", "entity/big-biter",
	 "entity/small-biter", "entity/character", "entity/medium-biter", "entity/character", "entity/big-biter",
	  "entity/small-biter", "entity/character", "entity/medium-biter", "entity/character", "entity/big-biter",
}

Global.register(
    {disabled_tabs=disabled_tabs, icons=icons},
    function(tbl)
        disabled_tabs = tbl.disabled_tabs
        icons = tbl.icons
    end
)
local Public = {}

Public.my_fixed_width_style = {
    minimal_width = 450,
    maximal_width = 450
}
Public.my_label_style = {
    single_line = false,
    font_color = {r=1,g=1,b=1},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_label_header_style = {
    single_line = false,
    font = "heading-1",
    font_color = {r=1,g=1,b=1},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_label_header_grey_style = {
    single_line = false,
    font = "heading-1",
    font_color = {r=0.6,g=0.6,b=0.6},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_note_style = {
    single_line = false,
    font = "default-small-semibold",
    font_color = {r=1,g=0.5,b=0.5},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_warning_style = {

    single_line = false,
    font_color = {r=1,g=0.1,b=0.1},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_spacer_style = {
    minimal_height = 10,
    top_padding = 0,
    bottom_padding = 0
}
Public.my_small_button_style = {
    font = "default-small-semibold"
}
Public.my_player_list_fixed_width_style = {
    minimal_width = 200,
    maximal_width = 400,
    maximal_height = 200
}
Public.my_player_list_admin_style = {
    font = "default-semibold",
    font_color = {r=1,g=0.5,b=0.5},
    minimal_width = 200,
    top_padding = 0,
    bottom_padding = 0,
    single_line = false,
}
Public.my_player_list_style = {
    font = "default-semibold",
    minimal_width = 200,
    top_padding = 0,
    bottom_padding = 0,
    single_line = false,
}
Public.my_player_list_offline_style = {
    font_color = {r=0.5,g=0.5,b=0.5},
    minimal_width = 200,
    top_padding = 0,
    bottom_padding = 0,
    single_line = false,
}
Public.my_player_list_style_spacer = {
    minimal_height = 20,
}
Public.my_color_red = {r=1,g=0.1,b=0.1}

Public.my_longer_label_style = {
    maximal_width = 600,
    single_line = false,
    font_color = {r=1,g=1,b=1},
    top_padding = 0,
    bottom_padding = 0
}
Public.my_longer_warning_style = {
    maximal_width = 600,
    single_line = false,
    font_color = {r=1,g=0.1,b=0.1},
    top_padding = 0,
    bottom_padding = 0
}

function Public.apply_direction_button_style(button)
    local button_style = button.style
    button_style.width = 24
    button_style.height = 24
    button_style.top_padding = 0
    button_style.bottom_padding = 0
    button_style.left_padding = 0
    button_style.right_padding = 0
    button_style.font = 'default-listbox'
end

function Public.apply_button_style(button)
    local button_style = button.style
    button_style.font = 'default-semibold'
    button_style.height = 26
    button_style.minimal_width = 26
    button_style.top_padding = 0
    button_style.bottom_padding = 0
    button_style.left_padding = 2
    button_style.right_padding = 2
end

--------------------------------------------------------------------------------
-- GUI Functions
--------------------------------------------------------------------------------

-- Apply a style option to a GUI
function Public.ApplyStyle (guiIn, styleIn)
    for k,v in pairs(styleIn) do
        guiIn.style[k]=v
    end
end

-- Shorter way to add a label with a style
function Public.AddLabel(guiIn, name, message, style)
    local g = guiIn.add{name = name, type = "label",
                    caption=message}
    if (type(style) == "table") then
        Public.ApplyStyle(g, style)
    else
        g.style = style
    end
end

function Public.AddLabelCaption(guiIn, name, style)
    local g = guiIn.add{type = "label",
                    caption=name}
    if (type(style) == "table") then
        Public.ApplyStyle(g, style)
    else
        g.style = style
    end
end

-- Shorter way to add a spacer
function Public.AddSpacer(guiIn)
    Public.ApplyStyle(guiIn.add{type = "label", caption=" "}, Public.my_spacer_style)
end

function Public.AddSpacerLine(guiIn)
    Public.ApplyStyle(guiIn.add{type = "line", direction="horizontal"}, Public.my_spacer_style)
end

function Public.get_tabs()
	return panel_tabs
end

function Public.get_disabled_tabs()
	return disabled_tabs
end


function Public.panel_clear_left_gui(player)
	local left = player.gui.left
	for _, child in pairs(left.children) do
		if child.name ~= "panel_button" and child.name ~= "mod_gui_frame_flow" then
			child.destroy()
		end
	end
end

function Public.refresh(player)
    local frame = Public.panel_get_active_frame(player)
    if not frame then return end

    local t = Public.get_content(player)

    for k, v in pairs(t.tabs) do
        v.content.clear()
    end
    Public.panel_refresh_active_tab(player)
end

function Public.get_panel(player)
	local left = player.gui.left
    if (left.panel == nil) then
        return nil
    else
        return left.panel
    end
end

function Public.panel_get_active_frame(player)
	local left = player.gui.left
	if not left.panel then return false end
	if not left.panel.next.tabbed_pane.selected_tab_index then return left.panel.next.tabbed_pane.tabs[1].content end
	return left.panel.next.tabbed_pane.tabs[left.panel.next.tabbed_pane.selected_tab_index].content
end

function Public.get_content(player)
	local left = player.gui.left
	if not left.panel then return false end
	return left.panel.next.tabbed_pane
end

function Public.panel_refresh_active_tab(player)
	local frame = Public.panel_get_active_frame(player)
	if not frame then return end
	panel_tabs[frame.name](player, frame)
end

local function top_button(player)
	if mod(player)["panel_top_button"] then return end
	local b = mod(player).add({type = "sprite-button", name = "panel_top_button", sprite = "utility/expand_dots", style=m_gui.button_style})
	b.style.padding=2
	b.style.width=20
end

local function main_frame(player)
	local left = player.gui.left
	local tabs = panel_tabs

	Public.panel_clear_left_gui(player)

    if (left.panel == nil) then



        local frame =left.add{type = 'frame', name = "panel", direction = "vertical"}
		frame.style.padding = 5
		table.shuffle_table(icons)
        local inside_frame = frame.add{type = "frame", name = "next", style = "inside_deep_frame", direction = "vertical"}
        local subhead = inside_frame.add{type = "frame", name = "sub_header", style = "changelog_subheader_frame"}

        Public.AddLabel(subhead, "scen_info", "We built this city ", "subheader_caption_label")
        for i = 1, 14, 1 do
        local e = subhead.add({type = "sprite", sprite = icons[i]})
        e.style.maximal_width = 24
        e.style.maximal_height = 24
        e.style.padding = 0
        end

        local t = inside_frame.add{name="tabbed_pane", type="tabbed-pane", style="tabbed_pane"}
		t.style.top_padding = 8

		for name, _ in pairs(tabs) do
			if name == "Admin" then
				if player.admin then
					local tab = t.add({type = "tab", caption = name})
					if disabled_tabs[name] == false then tab.enabled = false end
					local frame = t.add({type = "frame", name = name, direction = "vertical"})
					frame.style.left_margin = 10
					frame.style.right_margin = 10
					frame.style.top_margin = 4
					frame.style.bottom_margin = 4
					frame.style.padding = 5
					frame.style.horizontally_stretchable = true
					t.add_tab(tab, frame)
				end
			else
				local tab = t.add({type = "tab", caption = name})
				if disabled_tabs[name] == false then tab.enabled = false end
				local frame = t.add({type = "frame", name = name, direction = "vertical"})
				frame.style.left_margin = 10
				frame.style.right_margin = 10
				frame.style.top_margin = 4
				frame.style.bottom_margin = 4
				frame.style.padding = 5
				frame.style.horizontally_stretchable = true
				t.add_tab(tab, frame)
			end
		end
	end
	Public.panel_refresh_active_tab(player)
end

function Public.visible(player)
	local left = player.gui.left
    local frame = left.panel
    if (frame ~= nil) then
        frame.visible = not frame.visible
    end
end

function Public.panel_call_tab(player, name)
	local left = player.gui.left
	main_frame(player)
	local tabbed_pane = left.panel.next.tabbed_pane
	for key, v in pairs(tabbed_pane.tabs) do
		if v.tab.caption == name then
			tabbed_pane.selected_tab_index = key
			Public.panel_refresh_active_tab(player)
		end
	end
end

local function on_player_joined_game(event)
	top_button(game.players[event.player_index])
end

function Public.set_tab_on_init(tab_name, status)
       disabled_tabs[tab_name] = status
       return
end

function Public.set_tab(player, tab_name, status)
	local left = player.gui.left
	--Public.panel_call_tab(player, tab_name)
    local frame = Public.panel_get_active_frame(player)
    if not frame then disabled_tabs[tab_name] = status return end

    disabled_tabs[tab_name] = status
    if left.panel then
		left.panel.destroy()
		main_frame(player)
		return
    end
    Public.panel_refresh_active_tab(player)
end

local function on_gui_click(event)
    if not (event and event.element and event.element.valid) then return end
    local name = event.element.name
	local player = game.players[event.player_index]
	local left = player.gui.left

	if name == "panel_top_button" then
		if left.panel then
			left.panel.destroy()
			return
		else
			main_frame(player)
			return
		end
	end

	if not event.element.caption then return end
	if event.element.type ~= "tab" then return end
	Public.panel_refresh_active_tab(player)
	Public.refresh(player)
end

event.add(defines.events.on_player_joined_game, on_player_joined_game)
event.add(defines.events.on_gui_click, on_gui_click)

return Public