local StopData = {}

local mt = {__index = StopData}

function StopData:new(time, duration, signature)
	local stopData = {}

	stopData.time = time
	stopData.duration = duration
	stopData.signature = signature

	return setmetatable(stopData, mt)
end

function StopData:getDuration()
	return (self.duration * self.signature):tonumber()
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
