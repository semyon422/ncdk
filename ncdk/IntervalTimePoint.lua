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

function IntervalTimePoint:getBeatModulo()
	local measureData = self.measureData
	if not measureData then
		return self.time % 1
	end
	return (self.time - measureData.timePoint.time + measureData.start) % 1
end

local function add(intervalData, time)
	if intervalData.next and time >= intervalData:_end() then
		time = time - intervalData.beats
		intervalData = intervalData.next
		return add(intervalData, time)
	elseif intervalData.prev and time < intervalData:start() then
		intervalData = intervalData.prev
		time = time + intervalData.beats
		return add(intervalData, time)
	end
	return intervalData, time
end

function IntervalTimePoint:add(duration)
	return add(self.intervalData, self.time + duration)
end

local function sub(id1, t1, id2, t2)
	if id1 > id2 then
		return sub(id1.prev, t1 + id1.prev.beats, id2, t2)
	elseif id1 < id2 then
		return -sub(id2, t2, id1, t1)
	end
	return t1 - t2
end

function IntervalTimePoint:sub(timePoint)
	return sub(self.intervalData, self.time, timePoint.intervalData, timePoint.time)
end

function IntervalTimePoint:tonumber()
	local id = self.intervalData
	if type(id) == "number" then
		return id
	end
	local a, b, offset = id:getPair()
	if not a then
		return id.timePoint.absoluteTime
	end
	local ta = a.timePoint.absoluteTime
	local time = self.time - a:start() + (offset and a.beats or 0)
	return ta + a:getBeatDuration() * time
end

function IntervalTimePoint:fromnumber(id, t, limit, measureData, round)
	local a, b, offset = id:getPair()
	local time = (t - a.timePoint.absoluteTime) / a:getBeatDuration() + a:start()
	if offset then
		time = time - a.beats
		a = b
	end
	local measureOffset = measureData and measureData.timePoint.time - measureData.start or 0
	time = Fraction:new(time - measureOffset, limit, not not round) + measureOffset
	if not offset and time == a:_end() then
		time = b:start()
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
