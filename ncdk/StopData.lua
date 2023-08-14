local class = require("class")

local StopData = class()

function StopData:new(duration, isAbsolute)
	self.duration = duration
	self.isAbsolute = isAbsolute
end

function StopData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

function StopData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
end

function StopData.__eq(a, b)
	return a.timePoint == b.timePoint
end
function StopData.__lt(a, b)
	return a.timePoint < b.timePoint
end
function StopData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return StopData
