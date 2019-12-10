local Public = {}

Public.global_data = {
    chunk_size = 32,
    max_forces = 64,
    ticks_per_second = 60,
    ticks_per_minute = 3600,
    ticks_per_hour = 216000

}

function Public.get_table()
    return Public.global_data
end

return Public