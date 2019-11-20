local Event = require "utils.event"
local Global = require "utils.global"

local infinity_chests_storage = {}
local infinity_chests = {}
local infinity_chests_modes = {}
local infinity_chest_gui = {}

local format = string.format

Global.register(
    {infinity_chests = infinity_chests, infinity_chests_modes = infinity_chests_modes, infinity_chest_gui = infinity_chest_gui, infinity_chests_storage = infinity_chests_storage},
    function(tbl)
        infinity_chests = tbl.infinity_chests
        infinity_chest_gui = tbl.infinity_chest_gui
        infinity_chests_storage = tbl.infinity_chests_storage
        infinity_chests_modes = tbl.infinity_chests_modes
    end
)

local function sizeof(tbl)
  if not tbl then return 0 end
  local len = 0
  for k, _ in pairs(tbl) do
    len = len + 1
  end
  return len
end

local function validate_player(player)
  if not player then return false end
  if not player.valid then return false end
  if not player.character then return false end
  if not player.connected then return false end
  if not game.players[player.name] then return false end
  return true
end

local function built_entity(event)
  local entity =  event.created_entity
  if not entity.valid then return end
  if entity.name ~= "infinity-chest" then return end
  entity.active = false
  infinity_chests[entity.unit_number] = entity
  rendering.draw_text{
    text = "♾",
    surface = entity.surface,
    target = entity,
    target_offset = {0, -0.6},
    scale = 2,
    color = { r = 0, g = 0.6, b = 1},
    alignment = "center"
  }
end

local function mined_entity(event)
  local entity =  event.entity
  if entity.name ~= "infinity-chest" then return end
  infinity_chests[entity.unit_number]  = nil
  infinity_chests_storage[entity.unit_number]  = nil
  infinity_chests_modes[entity.unit_number]  = nil
end


local function item(item_name, item_count, inv, unit_number)

    local item_stack = game.item_prototypes[item_name].stack_size
    local diff = item_count - item_stack

    if not infinity_chests_storage[unit_number] then
      infinity_chests_storage[unit_number] = {}
    end
    local storage = infinity_chests_storage[unit_number]

    local mode = infinity_chests_modes[unit_number]
    if mode == 2 then
      diff = 2^31
    end

    if diff > 0 then
      local count = inv.remove({ name = item_name, count = diff})
      if not storage[item_name] then
        infinity_chests_storage[unit_number][item_name] = count
      else
        infinity_chests_storage[unit_number][item_name] = storage[item_name] + count
      end
    elseif diff < 0 then
      if not storage[item_name] then return end
      if storage[item_name] > (diff * -1) then
        local inserted = inv.insert({ name = item_name, count = (diff * -1)})
        infinity_chests_storage[unit_number][item_name] = storage[item_name] - inserted
      else
        inv.insert({ name = item_name, count = storage[item_name]})
        infinity_chests_storage[unit_number][item_name] = nil
      end
    end

end

local function update_chest(chest)
  for unit_number, chest in pairs(infinity_chests) do
    if not chest.valid then goto continue end
    local inv = chest.get_inventory(defines.inventory.chest)
    local content = inv.get_contents()

    local mode = infinity_chests_modes[chest.unit_number]
    if mode then
      if mode == 1 then
        inv.setbar()
      else
        inv.setbar(1)
      end
    end



    if sizeof(content) == 0 then
      chest.destructible = true
      chest.minable     = true
    else
      chest.destructible = false
      chest.minable     = false
    end

    for item_name, item_count in pairs(content) do
     item(item_name, item_count, inv, unit_number)
    end

    local storage = infinity_chests_storage[unit_number]
    if not storage then goto continue end
    for item_name, item_count in pairs(infinity_chests_storage[unit_number]) do
      if not content[item_name] then
        item(item_name, 0, inv, unit_number)
      end
     end

    ::continue::
  end
end

local function gui_opened(event)

  if not event.gui_type == defines.gui_type.entity then return end
  local entity = event.entity
  if not entity then return end
  if not entity.valid or entity.name ~= 'infinity-chest' then return end
  local player = game.players[event.player_index]
  local frame = player.gui.center.add{ type = "frame", caption = "Infinity Chest", direction = "vertical", name = entity.unit_number}
  local controls = frame.add{ type = "flow", direction = "horizontal"}
  local items = frame.add{ type = "flow", direction = "vertical"}

  local mode = infinity_chests_modes[entity.unit_number]
  local selected = mode and mode or 1

  local tbl = controls.add{ type = "table", column_count = 1}

  local text =
      tbl.add {
      type = 'label',
      caption = format('This chest stores unlimited quantity of items (up to 48 different item types).\nThe chest is best used with an inserter to add / remove items.\nThe chest is mineable if state is disabled or no items are stored.\nAll items are destroyed when mined.')
  }
  text.style.single_line = false

  local tbl_2 = tbl.add{ type = "table", column_count = 2}

  tbl_2.add{ type = "label", caption = "Mode: " }
  local drop_down = tbl_2.add{ type = "drop-down", items = {"Enabled", "Disabled"}, selected_index = selected, name = entity.unit_number }
  infinity_chests_modes[entity.unit_number] = drop_down.selected_index

  player.opened = frame
  infinity_chest_gui[player.name] = {
    item_frame = items,
    frame = frame,
    entity = entity,
    updated = false
  }
end

local function update_gui()
  for _, player in pairs(game.connected_players) do

    local chest_gui_data = infinity_chest_gui[player.name]
    if not chest_gui_data then goto continue end
    local frame = chest_gui_data.item_frame
    local entity = chest_gui_data.entity
    if not frame then goto continue end
    if not entity or not entity.valid then goto continue end
    local mode = infinity_chests_modes[entity.unit_number]
    if mode == 2 and infinity_chest_gui[player.name].updated then goto continue end
    frame.clear()

    local tbl = frame.add{ type = "table", column_count = 10, name = "infinity_chest_inventory" }
    local total = 0
    local items = {}

    local storage = infinity_chests_storage[entity.unit_number]

    if not storage then goto no_storage end
    for item_name, item_count in pairs(storage) do
      total = total +1
      items[item_name] = item_count
    end
    ::no_storage::

    local inv = entity.get_inventory(defines.inventory.chest)
    local content = inv.get_contents()

    for item_name, item_count in pairs(content) do
      if not items[item_name] then
        total = total + 1
        items[item_name] = item_count
      else
        items[item_name] = items[item_name] + item_count
      end
    end


    for item_name, item_count in pairs(items) do
      local btn = tbl.add{ type = "sprite-button", sprite = "item/"..item_name ,style = "slot_button", number = item_count, name = item_name}
    end

    while total < 48 do

      local btn = tbl.add{ type = "sprite-button", style = "slot_button"}
      btn.enabled = false

      total = total + 1
    end

    infinity_chest_gui[player.name].updated = true
    ::continue::
  end

end


local function gui_closed(event)
  local player = game.players[event.player_index]
  local type = event.gui_type

  if type == defines.gui_type.custom then
    local data = infinity_chest_gui[player.name]
    if not data then return end
    data.frame.destroy()
    infinity_chest_gui[player.name] = nil
  end
end

local function state_changed(event)
  local element = event.element
  local unit_number = tonumber(element.name)
  infinity_chests_modes[unit_number] = element.selected_index
  local chest = infinity_chests[unit_number]
end

local function gui_click(event)
  local element = event.element
  local player = game.players[event.player_index]
  if not validate_player(player) then return end
  if not element.valid then return end
  local parent = element.parent
  if not parent then return end
  if parent.name ~= "infinity_chest_inventory" then return end
  local unit_number = tonumber(parent.parent.parent.name)
  if tonumber(element.name) == unit_number then return end


  local shift = event.shift
  local ctrl = event.control
  local name = element.name
  local storage = infinity_chests_storage[unit_number]

  if ctrl then
    local count = storage[name]
    local inserted = player.insert{ name = name, count = count}
    if inserted == count then
      infinity_chests_storage[unit_number][name] = nil
    else
      infinity_chests_storage[unit_number][name] = infinity_chests_storage[unit_number][name] - inserted
    end
  elseif shift then
    local count = storage[name]
    local stack = game.item_prototypes[name].stack_size

    if count > stack then
      local inserted = player.insert{ name = name, count = stack}
      infinity_chests_storage[unit_number][name] = infinity_chests_storage[unit_number][name] - inserted
    else
      player.insert{ name = name, count = count}
      infinity_chests_storage[unit_number][name] = nil
    end
  else
    player.insert{ name = name, count = 1 }
    infinity_chests_storage[unit_number][name] = infinity_chests_storage[unit_number][name] - 1
    if infinity_chests_storage[unit_number][name] <= 0 then
      infinity_chests_storage[unit_number][name] = nil
    end
  end


  for _, p in pairs(game.connected_players) do
    if infinity_chest_gui[p.name] then
      infinity_chest_gui[p.name].updated = false
    end
  end
end

local function tick()
  update_chest()
  update_gui()
end

Event.add(defines.events.on_tick, tick)
Event.add(defines.events.on_gui_click, gui_click)
Event.add(defines.events.on_gui_opened, gui_opened)
Event.add(defines.events.on_gui_closed, gui_closed)
Event.add(defines.events.on_built_entity, built_entity)
Event.add(defines.events.on_robot_built_entity, built_entity)
Event.add(defines.events.on_player_mined_entity, mined_entity)
Event.add(defines.events.on_gui_selection_state_changed, state_changed)