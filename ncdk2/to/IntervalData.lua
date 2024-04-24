local TimedObject = require("ncdk2.to.TimedObject")

---@class ncdk2.IntervalData: ncdk2.TimedObject
---@operator call: ncdk2.IntervalData
---@field timePoint ncdk2.IntervalTimePoint
---@field next ncdk2.IntervalData?
---@field prev ncdk2.IntervalData?
local IntervalData = TimedObject + {}

---@param beats number
function IntervalData:new(beats)
	assert(type(beats) == "number" and beats >= 0 and beats % 1 == 0, "invalid beats: " .. beats)
	self.beats = beats
end

---@param beats number
---@return boolean
function IntervalData:set(beats)
	local _beats = self.beats
	self.beats = beats
	return _beats ~= beats
end

---@return ncdk.Fraction
function IntervalData:start()
	return self.timePoint.time % 1
end

---@return number
function IntervalData:startn()
	return self.timePoint.time:tonumber() % 1
end

---@return ncdk.Fraction
function IntervalData:_end()
	return self.next:start() + self.beats
end

---@return number
function IntervalData:getDuration()
	local duration = self.next:startn() - self:startn() + self.beats
	if duration <= 0 then
		error("zero interval duration found: " .. tostring(self) .. ", " .. tostring(self.next))
	end
	return duration
end

---@return number
function IntervalData:getBeatDuration()
	local a, b = self:getPair()
	local _a, _b = a.timePoint, b.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / a:getDuration()
end

---@return number
function IntervalData:getTempo()
	return 60 / self:getBeatDuration()
end

---@return ncdk2.IntervalData
---@return ncdk2.IntervalData
---@return boolean
function IntervalData:getPair()
	local a = self
	local n = a.next
	if n then
		return a, n, false
	end
	return a.prev, a, true
end

---@return boolean
function IntervalData:isSingle()
	return not self.prev and not self.next
end

---@param a ncdk2.IntervalData
---@return string
function IntervalData.__tostring(a)
	local time = a.timePoint:getAbsoluteTimeKey()
	return time .. "," .. a:start() .. "+" .. a.beats
end

-- use absoluteTime to prevent stackoverflow

---@param a ncdk2.IntervalData
---@param b ncdk2.IntervalData
---@return boolean
function IntervalData.__eq(a, b)
	return a.timePoint.absoluteTime == b.timePoint.absoluteTime
end

---@param a ncdk2.IntervalData
---@param b ncdk2.IntervalData
---@return boolean
function IntervalData.__lt(a, b)
	return a.timePoint.absoluteTime < b.timePoint.absoluteTime
end

---@param a ncdk2.IntervalData
---@param b ncdk2.IntervalData
---@return boolean
function IntervalData.__le(a, b)
	return a.timePoint.absoluteTime <= b.timePoint.absoluteTime
end

return IntervalData
