local Fraction = require("ncdk.Fraction")

local IntervalTime = {}

local mt = {__index = IntervalTime}

function IntervalTime:new(intervalData, time)
	local expandData = {}

	expandData.intervalData = intervalData
	expandData.time = time

	if type(intervalData) == "table" and intervalData.next then
		assert(time:tonumber() < intervalData.intervals)
	end

	return setmetatable(expandData, mt)
end

function IntervalTime:tonumber()
	local id = self.intervalData
	if type(id) == "number" then
		return id
	end
	local a, b, offset = id:getPair()
	if not a then
		return 0
	end
	local t = a.timePoint.absoluteTime
	if b then
		t = t + (b.timePoint.absoluteTime - t) * (self.time / a.intervals + (offset and 1 or 0))
	end
	return t
end

function IntervalTime:fromnumber(id, t, limit)
	local intervalData, nextIntervalData, offset = id:getPair()
	local _a, _b = intervalData.timePoint, nextIntervalData.timePoint
	local intervalTime = (t - _a.absoluteTime) / (_b.absoluteTime - _a.absoluteTime) * intervalData.intervals
	if offset then
		intervalTime = intervalTime - intervalData.intervals
		intervalData = nextIntervalData
	end
	return IntervalTime:new(intervalData, Fraction:new(intervalTime, limit, false))
end

function mt.__tostring(a)
	local time = a.intervalData
	if type(time) == "table" then
		time = time.timePoint.absoluteTime
	end
	return time .. "," .. a.time
end

local function isNumbers(a, b)
	local ia, ib = a.intervalData, b.intervalData
	local ta, tb = type(ia) == "table", type(ib) == "table"
	if ta and tb then
		return
	end
	if ta then
		ia = a:tonumber()
	end
	if tb then
		ib = b:tonumber()
	end
	return ia, ib
end

function mt.__eq(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na == nb
	end
	return a.intervalData == b.intervalData and a.time == b.time
end
function mt.__lt(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na < nb
	end
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time < b.time
end
function mt.__le(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na <= nb
	end
	return a.intervalData < b.intervalData or a.intervalData == b.intervalData and a.time <= b.time
end

return IntervalTime
