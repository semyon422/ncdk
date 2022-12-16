local IntervalTime = {}

local mt = {__index = IntervalTime}

function IntervalTime:new(intervalData, time)
	local expandData = {}

	expandData.intervalData = intervalData
	expandData.time = time

	return setmetatable(expandData, mt)
end

function mt.__tostring(a)
	local time = a.intervalData
	if type(time) == "table" then
		time = time.timePoint.absoluteTime
	end
	return time .. "," .. a.time
end

function mt.__eq(a, b)
	return a.intervalData == b.intervalData and a.time == b.time
end
function mt.__lt(a, b)
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time < b.time
end
function mt.__le(a, b)
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time <= b.time
end

return IntervalTime
