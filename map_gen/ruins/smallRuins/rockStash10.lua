
return function(center, surface) --suspicious rock, stash
    local ce = surface.create_entity --save typing
    local fN = game.forces.neutral
    local chest = ce{name = "wooden-chest", position = {center.x, center.y}, force = fN}
    chest.insert{name = "piercing-rounds-magazine", count = math.random(5, 50)}
    ce{name = "rock-big", position = {center.x, center.y}, force = fN}
end
