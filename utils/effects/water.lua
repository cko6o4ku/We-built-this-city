local function water_splash(surface, position)
  surface.create_entity({
    name = "water-splash",
    position = position
  })
end


return water_splash