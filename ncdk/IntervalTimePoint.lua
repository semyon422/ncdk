local TimePoint = require("ncdk.TimePoint")
local Fraction = require("ncdk.Fraction")

local IntervalTimePoint = TimePoint:new()

IntervalTimePoint.time = Fraction:new(0)
IntervalTimePoint.visualSide = -1

function IntervalTimePoint:setTime(intervalData, time, visualSide)
	self.intervalData = intervalData
	self.time = time
	self.visualSide = visualSide
	return self
end

function IntervalTimePoint:setTimeAbsolute(time, visualSide)
	self.absoluteTime = time
	self.intervalData = time
	self.time = nil
	self.visualSide = visualSide
	return self
end

function IntervalTimePoint:getTime()
	return self.intervalData, self.time, self.visualSide
end

function IntervalTimePoint:getKey()
	return tostring(self.intervalData) .. "," .. self.time .. "," .. self.visualSide
end

function IntervalTimePoint:tonumber()
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

function IntervalTimePoint:fromnumber(id, t, limit)
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
	self:setTime(a, time)
end

function IntervalTimePoint.__tostring(a)
	return ("%s,%s%s"):format(a.intervalData, a.time, a.visualSide == -1 and "<-" or "->")
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
		return na == nb
	end
	na, nb = a.intervalData, b.intervalData
	return na == nb and a.time == b.time and a.visualSide == b.visualSide
end
function IntervalTimePoint.__lt(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na < nb
	end
	na, nb = a.intervalData, b.intervalData
	return na < nb or na == nb and a.time < b.time or na == nb and a.time == b.time and a.visualSide < b.visualSide
end
function IntervalTimePoint.__le(a, b)
	local na, nb = isNumbers(a, b)
	if na then
		return na <= nb
	end
	na, nb = a.intervalData, b.intervalData
	return na < nb or na == nb and a.time < b.time or na == nb and a.time == b.time and a.visualSide <= b.visualSide
end

return IntervalTimePoint