local Loot = require 'features.modules.loot_items_v2'
return function(center, surface)
    local ce = surface.create_entity --save typing

    local fN = game.forces.enemy
    local direct = defines.direction


    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (-2.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (-6.0)}, direction = defines.direction.east, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (0.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-4.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-5.0)}, force = game.forces.enemy}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (-4.0)}, force = game.forces.neutral}.insert(Loot.loot)
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (-5.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (2.0), center.y + (-4.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-5.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-4.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-2.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (-3.0)}, force = game.forces.enemy}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-3.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (-2.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-2.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (-3.0)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (0.0)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (-7.0), center.y + (-1.0)}, force = game.forces.enemy}
    ce{name = "iron-chest", position = {center.x + (-6.0), center.y + (-1.0)}, force = game.forces.neutral}.insert(Loot.loot)
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-1.0), center.y + (-1.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (3.0), center.y + (0.0)}, force = game.forces.neutral}
    ce{name = "gate", position = {center.x + (5.0), center.y + (-1.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (0.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (2.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (1.0)}, force = game.forces.enemy}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-5.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-4.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-3.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (0.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (1.0), center.y + (1.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (3.0), center.y + (2.0)}, force = game.forces.neutral}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (1.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (2.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (4.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (3.0)}, force = game.forces.enemy}
    ce{name = "wooden-chest", position = {center.x + (-6.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "iron-chest", position = {center.x + (-4.0), center.y + (4.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-3.0), center.y + (3.0)}, force = game.forces.neutral}
    ce{name = "wooden-chest", position = {center.x + (-2.0), center.y + (3.0)}, force = game.forces.enemy}
    ce{name = "iron-chest", position = {center.x + (-1.0), center.y + (4.0)}, force = game.forces.enemy}
    ce{name = "iron-chest", position = {center.x + (2.0), center.y + (4.0)}, force = game.forces.neutral}.insert(Loot.loot)
    ce{name = "gun-turret", position = {center.x + (4.0), center.y + (-2.0)}, force = game.forces.enemy}.insert{name = "piercing-rounds-magazine", count = math.random(64, 100)}
    ce{name = "gun-turret", position = {center.x + (4.0), center.y + (2.0)}, force = game.forces.enemy}.insert{name = "piercing-rounds-magazine", count = math.random(64, 100)}
    ce{name = "gun-turret", position = {center.x + (-4.0), center.y + (-2.0)}, force = game.forces.enemy}.insert{name = "piercing-rounds-magazine", count = math.random(64, 100)}
    ce{name = "gun-turret", position = {center.x + (-4.0), center.y + (2.0)}, force = game.forces.enemy}.insert{name = "piercing-rounds-magazine", count = math.random(64, 100)}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (4.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (5.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-6.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-7.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-4.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-5.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-2.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (-3.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (0.0), center.y + (6.0)}, direction = defines.direction.east, force = game.forces.enemy}
    ce{name = "gate", position = {center.x + (-1.0), center.y + (6.0)}, direction = defines.direction.east, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (2.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (1.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (4.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (3.0), center.y + (6.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (5.0)}, force = game.forces.enemy}
    ce{name = "stone-wall", position = {center.x + (5.0), center.y + (6.0)}, force = game.forces.enemy}
end
