local function particles(surface, position)
  local particles = {
    "blood-particle",
    "coal-particle",
    "copper-ore-particle",
    "iron-ore-particle",
    "leaf-particle",
    "stone-particle",
    "wooden-particle",
  }
  for i = 1, 10 do

    local movement = { math.random(-50, 50) * 0.0008, math.random(-50, 50) * 0.0008 }
    surface.create_entity({
      name = particles[math.random(1, #particles)],
      position = position,
      movement = movement,
      height = math.random(-10, 10) * 0.01,
      vertical_speed = math.random(10, 50) * 0.005,
      frame_speed= 1
    })
  end
end

return particles