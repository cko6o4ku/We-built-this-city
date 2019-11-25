local P = require 'map_gen.shapes.patterns.patterns'
local Meta = require 'map_gen.shapes.metaconfig'

local Public = {}

local function eval(str)
    if false then -- string.find(str, "return", 1, true) ~= nil then
        return assert(load(str))()
    else
        return assert(load("return (" .. str .. ")"))()
    end
end

-- 'pattern' is a string containing Lua code.
-- 'vars' is a list of pairs (name, code) where name and code are strings,
-- and name contains a Lua variable, and code contains Lua code.
-- Each variable in vars can refer to the later variables, and pattern can refer to any of them.
-- 'vars' can be nil.
local function evaluate_pattern_with_context(pattern, vars)
    if vars == nil then
        return eval(pattern)
    end

    local env = {}
    setmetatable(env, {__index = _G})
    for i = 1, #vars do
        local item = vars[#vars - i + 1]
        local var_name = item[1]
        local var_value = eval(item[2], item[2], "t", env)
        env[var_name] = var_value
    end

    return eval(pattern, pattern, "t", env)
end

function Public.evaluate_pattern(map_name)

    local preset = Meta.preset_by_name(map_name)
    local pattern

    pattern = evaluate_pattern_with_context(preset)

    if pattern.output == "tilename" then
        return pattern
    elseif pattern.output == "bool" then
        return P.TP(pattern, nil, nil)
    elseif pattern.output == "tileid" then
        return P.TileID2Name(pattern, nil)
    else
        return nil
    end
end

return Public