local class = require("class")

---@class ncdk2.IntervalData
---@operator call: ncdk2.IntervalData
---@field timePoint ncdk2.IntervalTimePoint
---@field next ncdk2.IntervalData?
---@field prev ncdk2.IntervalData?
local IntervalData = class()

---@param offset number
function IntervalData:new(offset)
	self.offset = offset
end

---@return ncdk.Fraction
function IntervalData:time()
	return self.timePoint.time
end

---@return number
function IntervalData:getDuration()
	local duration = (self.next:time() - self:time()):tonumber()
	if duration <= 0 then
		error("zero interval duration found: " .. tostring(self) .. ", " .. tostring(self.next))
	end
	return duration
end

---@return number
function IntervalData:getBeatDuration()
	local a, b = self:getPair()
	return (b.offset - a.offset) / a:getDuration()
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
	return ("IntervalData(%s)"):format(a.offset)
end

return IntervalData
