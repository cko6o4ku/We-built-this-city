local Event = require "utils.event"
local Global = require "utils.global"

local this = {
  inf_chests = {},
  inf_storage = {},
  inf_mode = {},
  inf_gui = {},
  storage = {},
  stop = false
}

local format = string.format

local Public = {}

Public.storage = {}

Global.register(
    this,
    function(tbl)
        this = tbl
    end
)

function Public.get_table()
  return this
end

local function has_value(tab)
  local count = 0
  for _, k in pairs(tab) do count = count + 1 end
  return count
end

local function return_value(tab)
    for index, value in pairs(tab) do
      if value then
        local temp
        temp = value
        tab[index] = nil
        return temp
      end
    end
    return false
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
  if entity.name ~= "compilatron-chest" then return end
  if event.player_index then
    local player = game.get_player(event.player_index)
    if this.storage[player.index] then
      if this.stop then goto continue end
      local index = this.storage[player.index]
      this.inf_storage[entity.unit_number] = return_value(index)
    end
      ::continue::
      entity.active = false
      this.inf_chests[entity.unit_number] = entity
      this.inf_mode[entity.unit_number] = 1
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
end

local function built_entity_robot(event)
  local entity =  event.created_entity
  if not entity.valid then return end
  if entity.name ~= "compilatron-chest" then return end
  entity.destroy()
end

local function item(item_name, item_count, inv, unit_number)

    local item_stack = game.item_prototypes[item_name].stack_size
    local diff = item_count - item_stack

    if not this.inf_storage[unit_number] then
      this.inf_storage[unit_number] = {}
    end
    local storage = this.inf_storage[unit_number]

    local mode = this.inf_mode[unit_number]
    if mode == 2 then
      diff = 2^31
    end
    if diff > 0 then
      local count = inv.remove({ name = item_name, count = diff})
      if not storage[item_name] then
        this.inf_storage[unit_number][item_name] = count
      else
        this.inf_storage[unit_number][item_name] = storage[item_name] + count
      end
    elseif diff < 0 then
      if not storage[item_name] then return end
      if storage[item_name] > (diff * -1) then
        local inserted = inv.insert({ name = item_name, count = (diff * -1)})
        this.inf_storage[unit_number][item_name] = storage[item_name] - inserted
      else
        inv.insert({ name = item_name, count = storage[item_name]})
        this.inf_storage[unit_number][item_name] = nil
      end
    end
end

local function is_chest_empty(entity, player)
  local number = entity.unit_number
  local inv = this.inf_mode[number]

    if inv == 2 then
      for k, v in pairs(this.inf_storage) do
        if k == number then
          if not v then goto no_storage end
          if (has_value(v) >= 1) then
            this.storage[player][number] = this.inf_storage[number]
          end
        end
      end
      ::no_storage::

      this.inf_chests[number]  = nil
      this.inf_storage[number]  = nil
      this.inf_mode[number] = nil
    else
      this.inf_chests[number]  = nil
      this.inf_storage[number]  = nil
      this.inf_mode[number] = nil
    end
end

local function on_entity_died(event)
  local entity = event.entity
  if not entity then return end
  if entity.name ~= "compilatron-chest" then return end
  local number = entity.unit_number
    this.inf_mode[number] = nil
    this.inf_chests[number]  = nil
    this.inf_storage[number]  = nil
    this.inf_mode[number] = nil
end

local function on_pre_player_mined_item(event)
  local entity =  event.entity
  local player = game.players[event.player_index]
  if not player then return end
  if not this.storage[player.index] then
    this.storage[player.index] = {}
  end

  if entity.name ~= "compilatron-chest" then return end
    is_chest_empty(entity, player.index)
  local data = this.inf_gui[player.name]
  if not data then return end
  data.frame.destroy()
end

local function update_chest()
  for unit_number, chest in pairs(this.inf_chests) do
    if not chest.valid then goto continue end
    local inv = chest.get_inventory(defines.inventory.chest)
    local content = inv.get_contents()

    local mode = this.inf_mode[chest.unit_number]
    if mode then
      if mode == 1 then
        inv.setbar()
        chest.destructible = false
        chest.minable     = false
      else
        inv.setbar(1)
        chest.destructible = true
        chest.minable     = true
      end
    end

    for item_name, item_count in pairs(content) do
     item(item_name, item_count, inv, unit_number)
    end

    local storage = this.inf_storage[unit_number]
    if not storage then goto continue end
    for item_name, item_count in pairs(this.inf_storage[unit_number]) do
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
  if not entity.valid or entity.name ~= 'compilatron-chest' then return end
  local player = game.players[event.player_index]
  local frame = player.gui.center.add{ type = "frame", caption = "Compilatron Chest", direction = "vertical", name = entity.unit_number}
  local controls = frame.add{ type = "flow", direction = "horizontal"}
  local items = frame.add{ type = "flow", direction = "vertical"}

  local mode = this.inf_mode[entity.unit_number]
  local selected = mode and mode or 1
  local tbl = controls.add{ type = "table", column_count = 1}

  local text =
      tbl.add {
      type = 'label',
      caption = format('This chest stores unlimited quantity of items (up to 48 different item types).\nThe chest is best used with an inserter to add / remove items.\nThe chest is mineable if state is disabled.\nContent is kept when mined.')
  }
  text.style.single_line = false

  local tbl_2 = tbl.add{ type = "table", column_count = 2}

  tbl_2.add{ type = "label", caption = "Mode: " }
  local drop_down = tbl_2.add{ type = "drop-down", items = {"Enabled", "Disabled"}, selected_index = selected, name = entity.unit_number }
  this.inf_mode[entity.unit_number] = drop_down.selected_index
  player.opened = frame
  this.inf_gui[player.name] = {
    item_frame = items,
    frame = frame,
    entity = entity,
    updated = false
  }
end

local function update_gui()
  for _, player in pairs(game.connected_players) do

    local chest_gui_data = this.inf_gui[player.name]
    if not chest_gui_data then goto continue end
    local frame = chest_gui_data.item_frame
    local entity = chest_gui_data.entity
    if not frame then goto continue end
    if not entity or not entity.valid then goto continue end
    local mode = this.inf_mode[entity.unit_number]
    if mode == 2 and this.inf_gui[player.name].updated then goto continue end
    frame.clear()

    local tbl = frame.add{ type = "table", column_count = 10, name = "compilatron_chest_inventory" }
    local total = 0
    local items = {}

    local storage = this.inf_storage[entity.unit_number]

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

    local btn
    for item_name, item_count in pairs(items) do
      if mode == 1 then
      btn = tbl.add{ type = "sprite-button", sprite = "item/"..item_name ,style = "slot_button", number = item_count, name = item_name, tooltip = "Withdrawal is possible when state is disabled!"}
      btn.enabled = false
    elseif mode == 2 then
      btn = tbl.add{ type = "sprite-button", sprite = "item/"..item_name ,style = "slot_button", number = item_count, name = item_name}
      btn.enabled = true
    end
    end

    while total < 48 do

      local btns = tbl.add{ type = "sprite-button", style = "slot_button"}
      btns.enabled = false

      total = total + 1
    end

    this.inf_gui[player.name].updated = true
    ::continue::
  end

end


local function gui_closed(event)
  local player = game.players[event.player_index]
  local type = event.gui_type

  if type == defines.gui_type.custom then
    local data = this.inf_gui[player.name]
    if not data then return end
    data.frame.destroy()
    this.inf_gui[player.name] = nil
  end
end

local function state_changed(event)
  local element = event.element
  if not element.valid then return end
  if not element.selected_index then return end
  local unit_number = tonumber(element.name)
  if not unit_number then return end
  if not this.inf_mode[unit_number] then return end
  this.inf_mode[unit_number] = element.selected_index
  local mode = this.inf_mode[unit_number]
  if mode == 2 then
    local player = game.players[event.player_index]
    if not validate_player(player) then return end
    this.inf_gui[player.name].updated = false
  end
end

local function gui_click(event)
  local element = event.element
  local player = game.players[event.player_index]
  if not validate_player(player) then return end
  if not element.valid then return end
  local parent = element.parent
  if not parent then return end
  if parent.name ~= "compilatron_chest_inventory" then return end
  local unit_number = tonumber(parent.parent.parent.name)
  if tonumber(element.name) == unit_number then return end


  local shift = event.shift
  local ctrl = event.control
  local name = element.name
  local storage = this.inf_storage[unit_number]

  if this.inf_mode[unit_number] == 1 then return end

  if ctrl then
    local count = storage[name]
    if not count then return end
    local inserted = player.insert{ name = name, count = count}
    if not inserted then return end
    if inserted == count then
      this.inf_storage[unit_number][name] = nil
    else
      this.inf_storage[unit_number][name] = this.inf_storage[unit_number][name] - inserted
    end
  elseif shift then
    local count = storage[name]
    local stack = game.item_prototypes[name].stack_size
    if not count then return end
    if not stack then return end
    if count > stack then
      local inserted = player.insert{ name = name, count = stack}
      this.inf_storage[unit_number][name] = this.inf_storage[unit_number][name] - inserted
    else
      player.insert{ name = name, count = count}
      this.inf_storage[unit_number][name] = nil
    end
  else
    if not this.inf_storage[unit_number][name] then return end
    this.inf_storage[unit_number][name] = this.inf_storage[unit_number][name] - 1
    player.insert{ name = name, count = 1 }
    if this.inf_storage[unit_number][name] <= 0 then
      this.inf_storage[unit_number][name] = nil
    end
  end


  for _, p in pairs(game.connected_players) do
    if this.inf_gui[p.name] then
      this.inf_gui[p.name].updated = false
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
Event.add(defines.events.on_robot_built_entity, built_entity_robot)
Event.add(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
Event.add(defines.events.on_gui_selection_state_changed, state_changed)
Event.add(defines.events.on_entity_died, on_entity_died)

return Public