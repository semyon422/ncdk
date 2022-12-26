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
	local a, b, offset = id:getPair()
	local ta, tb = a.timePoint, b.timePoint
	local time = (t - ta.absoluteTime) / (tb.absoluteTime - ta.absoluteTime) * a.intervals
	if offset then
		time = time - a.intervals
		a = b
	end
	time = Fraction:new(time, limit, false)
	if time:floor() == a.intervals and a.next then
		a = a.next
		time = Fraction:new(0)
	end
	return IntervalTime:new(a, time)
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
	ia = type(ia) == "number" and ia or ia.timePoint.absoluteTime
	ib = type(ib) == "number" and ib or ib.timePoint.absoluteTime
	return ia, ib
end

function mt.__eq(a, b)
	local na, nb = isNumbers(a, b)
	return na == nb and a.time == b.time
end
function mt.__lt(a, b)
	local na, nb = isNumbers(a, b)
	return na < nb or na == nb and a.time < b.time
end
function mt.__le(a, b)
	local na, nb = isNumbers(a, b)
	return na < nb or na == nb and a.time <= b.time
end

return IntervalTime
