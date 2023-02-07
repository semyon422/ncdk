local TimePoint = require("ncdk.TimePoint")
local Fraction = require("ncdk.Fraction")

local IntervalTimePoint = TimePoint:new()

IntervalTimePoint.time = Fraction:new(0)
IntervalTimePoint.visualSide = 0

function IntervalTimePoint:setTime(intervalData, time, visualSide)
	self.intervalData = intervalData
	self.time = time
	self.visualSide = visualSide
	return self
end

function IntervalTimePoint:setTimeAbsolute(time, visualSide)
	assert(type(time) == "number")
	self.absoluteTime = time
	self.intervalData = time
	self.time = nil
	self.visualSide = visualSide
	return self
end

function IntervalTimePoint:getTime()
	return self.intervalData, self.time, self.visualSide
end

function IntervalTimePoint:getPrevVisualTime()
	return self.intervalData, self.time, self.visualSide - 1
end

function IntervalTimePoint:tonumber()
	local id = self.intervalData
	if type(id) == "number" then
		return id
	end
	local a, b, offset = id:getPair()
	if not a then
		return not b and 0 or a.timePoint.absoluteTime
	end

	local ta = a.timePoint.absoluteTime
	local time = self.time - a.start + (offset and a.beats or 0)
	return ta + a:getBeatDuration() * time
end

function IntervalTimePoint:fromnumber(id, t, limit)
	local a, b, offset = id:getPair()
	local time = (t - a.timePoint.absoluteTime) / a:getBeatDuration() + a.start
	if offset then
		time = time - a.beats
		a = b
	end
	time = Fraction:new(time, limit, false)
	if not offset and time == a:_end() then
		time = b.start
		a = b
	end
	self:setTime(a, time)
end

function IntervalTimePoint.__tostring(a)
	return ("(%s,%s,%s)"):format(a.intervalData, a.time, a.visualSide)
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

function IntervalTimePoint.__eq(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na == nb and a.visualSide == b.visualSide
	end
	na, nb = a.intervalData, b.intervalData
	return na == nb and a.time == b.time and a.visualSide == b.visualSide
end
function IntervalTimePoint.__lt(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na < nb or na == nb and a.visualSide < b.visualSide
	end
	na, nb = a.intervalData, b.intervalData
	return na < nb or na == nb and a.time < b.time or na == nb and a.time == b.time and a.visualSide < b.visualSide
end
function IntervalTimePoint.__le(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na < nb or na == nb and a.visualSide <= b.visualSide
	end
	na, nb = a.intervalData, b.intervalData
	return na < nb or na == nb and a.time < b.time or na == nb and a.time == b.time and a.visualSide <= b.visualSide
end

return IntervalTimePoint
