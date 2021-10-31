--- foxdot library
foxdot = {}

foxdot._fns = {} -- default char meanings!
-- { ['1'] = function() output[1]() end
-- , ['2'] = function() output[2]() end
-- , ['3'] = function() output[3]() end
-- , ['4'] = function() output[4]() end
-- , a = function() output[1](ar()) end
-- , b = function() output[2](ar()) end
-- , c = function() output[3](ar()) end
-- , d = function() output[4](ar()) end
-- }

foxdot.go = function(c, ...)
	local cc = foxdot._fns[c]
	if cc then return cc(...) end -- return for meta-actions?
end

foxdot.__call = function(f, c, ...) return foxdot.go(c, ...) end
foxdot.__newindex = foxdot._fns
foxdot.__index = foxdot._fns

return setmetatable(foxdot, foxdot)
