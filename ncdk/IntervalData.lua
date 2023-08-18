local class = require("class")

---@class ncdk.IntervalData
---@operator call: ncdk.IntervalData
local IntervalData = class()

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
	if not a then
		return math.huge
	end
	local _a, _b = a.timePoint, b.timePoint
	return (_b.absoluteTime - _a.absoluteTime) / a:getDuration()
end

---@return number
function IntervalData:getTempo()
	return 60 / self:getBeatDuration()
end

---@return ncdk.IntervalData?
---@return ncdk.IntervalData?
---@return boolean?
function IntervalData:getPair()
	local a = self
	local n = a.next
	if n then
		return a, n
	end
	local p = a.prev
	if not p then
		return
	end
	return p, a, true
end

---@param a ncdk.IntervalData
---@return string
function IntervalData.__tostring(a)
	local time = a.timePoint:getAbsoluteTimeKey()
	return time .. "," .. a:start() .. "+" .. a.beats
end

-- use absoluteTime to prevent stackoverflow

---@param a ncdk.IntervalData
---@param b ncdk.IntervalData
---@return boolean
function IntervalData.__eq(a, b)
	return a.timePoint.absoluteTime == b.timePoint.absoluteTime
end

---@param a ncdk.IntervalData
---@param b ncdk.IntervalData
---@return boolean
function IntervalData.__lt(a, b)
	return a.timePoint.absoluteTime < b.timePoint.absoluteTime
end

---@param a ncdk.IntervalData
---@param b ncdk.IntervalData
---@return boolean
function IntervalData.__le(a, b)
	return a.timePoint.absoluteTime <= b.timePoint.absoluteTime
end

return IntervalData
