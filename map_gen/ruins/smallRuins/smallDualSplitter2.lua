
return function(center, surface) -- small dual splitter
    local ce = surface.create_entity --save typing
    local fN = game.forces.neutral
    local direct = defines.direction

    ce{name="transport-belt", position={center.x + (1.0), center.y + (-1.0)}, force=game.forces.neutral}.damage(114,"neutral","physical")
    ce{name="splitter", position={center.x + (0.0), center.y + (-0.5)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="splitter", position={center.x + (-1.0), center.y + (0.5)}, direction=defines.direction.west, force=game.forces.neutral}.damage(36,"neutral","physical")
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (-2.0), center.y + (0.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (0.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (1.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(29,"neutral","physical")
    ce{name="transport-belt", position={center.x + (2.0), center.y + (0.0)}, direction=defines.direction.west, force=game.forces.neutral}
    ce{name="transport-belt", position={center.x + (2.0), center.y + (1.0)}, direction=defines.direction.west, force=game.forces.neutral}.damage(56,"neutral","physical")
    ce{name="transport-belt", position={center.x + (3.0), center.y + (0.0)}, direction=defines.direction.west, force=game.forces.neutral}

end
