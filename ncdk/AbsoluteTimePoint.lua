local TimePoint = require("ncdk.TimePoint")

---@class ncdk.AbsoluteTimePoint: ncdk.TimePoint
---@operator call: ncdk.AbsoluteTimePoint
local AbsoluteTimePoint = TimePoint + {}

AbsoluteTimePoint.visualSide = 0

---@param time number
---@param visualSide number?
---@return ncdk.AbsoluteTimePoint
function AbsoluteTimePoint:setTime(time, visualSide)
	assert(type(time) == "number")
	self.absoluteTime = time
	self.visualSide = visualSide
	return self
end

AbsoluteTimePoint.setTimeAbsolute = AbsoluteTimePoint.setTime

---@return number
---@return number
function AbsoluteTimePoint:getTime()
	return self.absoluteTime, self.visualSide
end

---@return number
---@return number
function AbsoluteTimePoint:getPrevVisualTime()
	return self.absoluteTime, self.visualSide - 1
end

---@param a ncdk.AbsoluteTimePoint
---@return string
function AbsoluteTimePoint.__tostring(a)
	return ("(%s,%s)"):format(a:getAbsoluteTimeKey(), a.visualSide)
end

---@param a ncdk.TimePoint
---@param b ncdk.TimePoint
---@return boolean
function AbsoluteTimePoint.__eq(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at == bt and a.visualSide == b.visualSide
end

---@param a ncdk.TimePoint
---@param b ncdk.TimePoint
---@return boolean
function AbsoluteTimePoint.__lt(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at < bt or (at == bt and a.visualSide < b.visualSide)
end

---@param a ncdk.TimePoint
---@param b ncdk.TimePoint
---@return boolean
function AbsoluteTimePoint.__le(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at < bt or at == bt and a.visualSide <= b.visualSide
end

return AbsoluteTimePoint
