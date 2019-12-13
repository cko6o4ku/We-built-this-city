local Global = require "utils.global"

local this = {
    groups = {},
    ranks = {},
    meta = {},
    old = {},
    current = {},
    last_jail = nil
}

Global.register(
	this,
	function(t)
		this = t
	end
)

local Public = {}

function Public.get_table()
    return this
end

return Public