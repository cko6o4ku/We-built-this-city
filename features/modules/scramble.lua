global.diversity_quote = 0.20
global.exempt_area = 200 --This is the radius of the starting area that can't be affected.
global.stone_byproduct = false --Delete patches of stone.  Stone only appears as a byproduct.
global.stone_byproduct_ratio = 0.25 --If math.random() is between diversity_quote and this, it's stone.

local Public = {}
global.diverse_ores = {}
--Build a table of potential ores to pick from.  Uranium is exempt from popping up randomly.
function Public.init()
	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource" and v.resource_category == "basic-solid" and v.mineable_properties.required_fluid == nil then
			table.insert(global.diverse_ores, v.name)
		end
	end
end

function Public.scramble(event)
	local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
		if math.abs(v.position.x) > global.exempt_area or math.abs(v.position.y) > global.exempt_area then
			if v.prototype.resource_category == "basic-solid" then
				local random = math.random()
				if v.name == "stone" and global.stone_byproduct then
					v.destroy()
				elseif random < global.diversity_quote then --Replace!
					local refugee = global.diverse_ores[math.random(#global.diverse_ores)]
					event.surface.create_entity{name=refugee, position=v.position, amount=v.amount}
					v.destroy()
				elseif global.stone_byproduct and random < global.stone_byproduct_ratio then --Replace with stone!
					event.surface.create_entity{name="stone", position=v.position, amount=v.amount}
					v.destroy()
				end
			end
		end
	end
end

return Public

