local Market = require 'features.functions.basic_markets'
local Loot = require 'features.modules.loot_items_v2'
local Event = require 'utils.event'
local Fort = require 'features.modules.spawn_ent.spawn_ent_roughFort'
--local StorageLoot = require 'features.modules.spawn_ent.spawn_ent_storageArea'
local m_random = math.random

local Public = {}

local function m_clearArea(center, surface)
    for y = center.y-8, center.y+8 do
        for x = center.x-8, center.x+8 do
            if surface.get_tile(x, y).name == "water" or surface.get_tile(x, y).name == "deepwater" then
                return false
            end
        end
    end

    for index, entity in pairs(surface.find_entities({{center.x-8,center.y-8},{center.x+8,center.y+8}})) do
        if entity.valid and entity.type ~= "resource" then
            entity.destroy()
        end
    end

    return true
end

local function probability(v1, v2)
    return m_random(v1, v2) >= v2
end

local function spawn_market(center, surface)
	local pos = {x=center.x, y=center.y}
    if m_clearArea(center, surface) then
		if probability(1,2) then
			Market.mountain_market(surface, center, math.abs(center.y) * 0.004)
			if _DEBUG then
				game.print("Spawned market_y at: x=" ..pos.x.. ", y=" ..  pos.y)
			end
		else
			Market.mountain_market(surface, center, math.abs(center.x) * 0.004)
			if _DEBUG then
				game.print("Spawned market_x at: x=" ..pos.x.. ", y=" ..  pos.y)
			end
		end
		return
    end
end

local function spawn_loot(center, surface)
	local pos = {x=center.x, y=center.y}
	local name = "crash-site-chest-1"
	if probability(1,2) then name = "crash-site-chest-2" end
    if m_clearArea(center, surface) then
		if probability(1,2) then
			Loot.add(surface, center, name)
			Fort(center, surface)
		else
			Loot.add(surface, center, name)
		--	StorageLoot(center, surface)
		end
		if _DEBUG then
			game.print("Spawned chest at: x=" ..pos.x.. ", y=" ..  pos.y)
		end
    end
end

local function ticker (e)
    local center = {x=(e.area.left_top.x+e.area.right_bottom.x)/2, y=(e.area.left_top.y+e.area.right_bottom.y)/2}
    if math.abs(center.x) < 200 and math.abs(center.y) < 200 then return end --too close to spawn

	if probability(1, 120) then
		center.x = center.x + m_random(-10,10)
		center.y = center.y + m_random(-10,10)
		spawn_market(center, e.surface)
    end
	if probability(1, 80) then
		center.x = center.x + math.random(-5,5)
		center.y = center.y + math.random(-5,5)
		spawn_loot(center, e.surface)
    end
end

Event.add(defines.events.on_chunk_generated, ticker)

return Public