local StopData = {}

local mt = {__index = StopData}

function StopData:new(duration, isAbsolute)
	local stopData = {}

	stopData.duration = duration
	stopData.isAbsolute = isAbsolute

	return setmetatable(stopData, mt)
end

function StopData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

function mt.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
end

function mt.__eq(a, b)
	return a.timePoint == b.timePoint
end
function mt.__lt(a, b)
	return a.timePoint < b.timePoint
end
function mt.__le(a, b)
	return a.timePoint <= b.timePoint
end

return StopData
