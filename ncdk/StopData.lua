local StopData = {}

local mt = {__index = StopData}

function StopData:new(time, duration)
	local stopData = {}

	stopData.time = time
	stopData.duration = duration

	return setmetatable(stopData, mt)
end

function StopData:set(duration, signature)
	local _duration = self.duration
	self.duration = duration
	self.signature = signature
	return _duration ~= duration
end

function mt.__tostring(a)
	return a.time .. "," .. a.duration .. "," .. a.signature
end

function mt.__eq(a, b)
	return a.time == b.time
end
function mt.__lt(a, b)
	return a.time < b.time
end
function mt.__le(a, b)
	return a.time <= b.time
end

return StopData
