local DIVERSITY_QUOTA = 0.20
local EXEMPT_AREA = 200 --This is the radius of the starting area that can't be affected.
local STONE_BYPRODUCT = false --Delete patches of stone.  Stone only appears as a byproduct.
local STONE_BYPRODUCT_RATIO = 0.25 --If math.random() is between DIVERSITY_QUOTA and this, it's stone.

local Public = {}
--Build a table of potential ores to pick from.  Uranium is exempt from popping up randomly.
function Public.init()
	global.diverse_ores = {}
	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource" and v.resource_category == "basic-solid" and v.mineable_properties.required_fluid == nil then
			table.insert(global.diverse_ores, v.name)
		end
	end
end

function Public.scramble(event)
	local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
		if math.abs(v.position.x) > EXEMPT_AREA or math.abs(v.position.y) > EXEMPT_AREA then
			if v.prototype.resource_category == "basic-solid" then
				local random = math.random()
				if v.name == "stone" and STONE_BYPRODUCT then
					v.destroy()
				elseif random < DIVERSITY_QUOTA then --Replace!
					local refugee = global.diverse_ores[math.random(#global.diverse_ores)]
					event.surface.create_entity{name=refugee, position=v.position, amount=v.amount}
					v.destroy()
				elseif STONE_BYPRODUCT and random < STONE_BYPRODUCT_RATIO then --Replace with stone!
					event.surface.create_entity{name="stone", position=v.position, amount=v.amount}
					v.destroy()
				end
			end
		end
	end
end

return Public

