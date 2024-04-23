local TimePoint = require("ncdk2.tp.TimePoint")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.IntervalTimePoint: ncdk2.TimePoint
---@operator call: ncdk2.IntervalTimePoint
---@field _measureData ncdk2.MeasureData?
---@field measureData ncdk2.MeasureData?
---@field _intervalData ncdk2.IntervalData?
---@field intervalData ncdk2.IntervalData?
local IntervalTimePoint = TimePoint + {}

IntervalTimePoint.time = Fraction(0)

---@param intervalData number|ncdk2.IntervalData
---@param time ncdk.Fraction?
---@return ncdk2.IntervalTimePoint
function IntervalTimePoint:setTime(intervalData, time)
	self.intervalData = intervalData
	self.time = time
	return self
end

---@param time number
---@param visualSide number?
---@return ncdk2.IntervalTimePoint
function IntervalTimePoint:setTimeAbsolute(time, visualSide)
	assert(type(time) == "number")
	self.absoluteTime = time
	self.intervalData = time
	self.time = nil
	self.visualSide = visualSide
	return self
end

---@return number|ncdk2.IntervalData
---@return ncdk.Fraction
---@return number
function IntervalTimePoint:getTime()
	return self.intervalData, self.time, self.visualSide
end

---@return number|ncdk2.IntervalData
---@return ncdk.Fraction
---@return number
function IntervalTimePoint:getPrevVisualTime()
	return self.intervalData, self.time, self.visualSide - 1
end

---@return ncdk.Fraction
function IntervalTimePoint:getBeatModulo()
	local measureData = self.measureData
	if not measureData then
		return self.time % 1
	end
	return (self.time - measureData.timePoint.time + measureData.start) % 1
end

---@param intervalData ncdk2.IntervalData
---@param time ncdk.Fraction
---@return ncdk2.IntervalData
---@return ncdk.Fraction
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

---@param duration ncdk.Fraction
---@return ncdk2.IntervalData
---@return ncdk.Fraction
function IntervalTimePoint:add(duration)
	return add(self.intervalData --[[@as ncdk2.IntervalData]], self.time + duration)
end

---@param id1 ncdk2.IntervalData
---@param t1 ncdk.Fraction
---@param id2 ncdk2.IntervalData
---@param t2 ncdk.Fraction
---@return ncdk.Fraction
local function sub(id1, t1, id2, t2)
	if id1 > id2 then
		return sub(id1.prev, t1 + id1.prev.beats, id2, t2)
	elseif id1 < id2 then
		return -sub(id2, t2, id1, t1)
	end
	return t1 - t2
end

---@param timePoint ncdk2.TimePoint
---@return ncdk.Fraction
function IntervalTimePoint:sub(timePoint)
	return sub(
		self.intervalData --[[@as ncdk2.IntervalData]],
		self.time,
		timePoint.intervalData,
		timePoint.time
	)
end

---@return number
function IntervalTimePoint:tonumber()
	local id = self.intervalData
	if type(id) == "number" then
		return id
	end
	if id:isSingle() then
		return id.timePoint.absoluteTime
	end
	local a, b, offset = id:getPair()
	local ta = a.timePoint.absoluteTime
	local time = self.time:tonumber() - a:startn() + (offset and a.beats or 0)
	return ta + a:getBeatDuration() * time
end

---@param id ncdk2.IntervalData
---@param t number
---@param limit number
---@param measureData ncdk2.MeasureData?
---@param round boolean?
function IntervalTimePoint:fromnumber(id, t, limit, measureData, round)
	local a, b, offset = id:getPair()
	local time = (t - a.timePoint.absoluteTime) / a:getBeatDuration() + a:start()
	if offset then
		time = time - a.beats
		a = b
	end
	local measureOffset = measureData and measureData.timePoint.time - measureData.start or 0
	time = Fraction(time - measureOffset, limit, not not round) + measureOffset
	if not offset and time == a:_end() then
		time = b:start()
		a = b
	end
	self:setTime(a, time)
end

---@param a ncdk2.IntervalTimePoint
---@return string
function IntervalTimePoint.__tostring(a)
	return ("(%s,%s,%s)"):format(a.intervalData, a.time, a.visualSide)
end

return IntervalTimePoint
