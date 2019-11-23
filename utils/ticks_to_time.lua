local function ticks_to_time(ticks)
  local seconds = ticks / 60
  local hours   = math.floor(seconds / 60 / 60) % 60
  local minutes = math.floor(seconds / 60) % 60
  seconds       = math.floor(seconds % 60)
  local hour_string    = (hours > 0 and (hours == 1 and hours .. " hour" or hours .. " hours") or "")
  local minute_string  = (minutes > 0 and (minutes == 1 and minutes .. " min" or minutes .. " mins") or "")
  local second_string  = (seconds > 0 and seconds .. " sec" or "")
  
  
  return hour_string.." "..minute_string.." "..second_string
end


return ticks_to_time