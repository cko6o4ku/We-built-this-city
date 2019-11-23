local function dist(from, to)
  if not from.x then
    from = { x = from[1], y = from[2] }
  end

  if not to.x then
    to = { x = to[1], y = to[2] }
  end
  local d = math.sqrt( ((from.x - to.x)^2) + ((from.y - to.y)^2) )
  return d % 1 >= 0.5 and math.ceil(d) or math.floor(d)
end



return dist