local Global = require 'utils.global'

local Public = {}

local global_data = {
    chunk_size = 32,
    max_forces = 64,
    ticks_per_second = 60,
    ticks_per_minute = 3600,
    ticks_per_hour = 216000

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

return Public