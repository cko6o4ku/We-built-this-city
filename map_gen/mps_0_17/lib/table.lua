local Global = require 'utils.global'

local Public = {}

local global_data = {
    chunk_size = 32,
    max_forces = 64,
    ticks_per_second = 60,
    ticks_per_minute = 3600,
    ticks_per_hour = 216000,
    removal_list = {}

}

Global.register(
    global_data,
    function(tbl)
        global_data = tbl
    end
)

function Public.get_table()
    return global_data
end

function Public.set_data(key, value)
    if not global_data[key] then global_data.key = {} end
    global_data[key] = value
end

return Public