local TimePoint = require("ncdk.TimePoint")

---@class ncdk.MeasureTimePoint
---@operator call: ncdk.MeasureTimePoint
local MeasureTimePoint = TimePoint + {}

MeasureTimePoint.side = 0
MeasureTimePoint.visualSide = 0

---@param time ncdk.Fraction
---@param side number?
---@param visualSide number?
---@return ncdk.MeasureTimePoint
function MeasureTimePoint:setTime(time, side, visualSide)
	assert(type(time) == "table")
	self.measureTime = time
	self.side = side
	self.visualSide = visualSide
	return self
end

---@param time number
---@param visualSide number?
---@return ncdk.MeasureTimePoint
function MeasureTimePoint:setTimeAbsolute(time, visualSide)
	assert(type(time) == "number")
	self.measureTime = nil
	self.absoluteTime = time
	self.side = nil
	self.visualSide = visualSide
	return self
end

---@return ncdk.Fraction
---@return number?
---@return number?
function MeasureTimePoint:getTime()
	return self.measureTime, self.side, self.visualSide
end

---@return ncdk.Fraction
---@return number
---@return number
function MeasureTimePoint:getPrevTime()
	return self.measureTime, self.side - 1, 0
end

---@return ncdk.Fraction
---@return number?
---@return number
function MeasureTimePoint:getPrevVisualTime()
	return self.measureTime, self.side, self.visualSide - 1
end

---@return number
function MeasureTimePoint:tonumber()
	return self.measureTime:tonumber()
end

---@param a ncdk.MeasureTimePoint
---@return string
function MeasureTimePoint.__tostring(a)
	if a.measureTime then
		return ("(%s,%s,%s)"):format(a.measureTime, a.side, a.visualSide)
	end
	return ("(A%s,%s,%s)"):format(a.absoluteTime, a.side, a.visualSide)
end

---@param a ncdk.MeasureTimePoint
---@param b ncdk.MeasureTimePoint
---@return number|ncdk.Fraction
---@return number|ncdk.Fraction
local function getTimes(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime, b.measureTime
	end
	return a.absoluteTime, b.absoluteTime
end

---@param a ncdk.MeasureTimePoint
---@param b ncdk.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__eq(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at == bt and a.visualSide == b.visualSide
	end
	return at == bt and a.side == b.side and a.visualSide == b.visualSide
end

---@param a ncdk.MeasureTimePoint
---@param b ncdk.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__lt(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at < bt or (at == bt and a.visualSide < b.visualSide)
	end
	return at < bt or at == bt and a.side < b.side or at == bt and a.side == b.side and a.visualSide < b.visualSide
end

---@param a ncdk.MeasureTimePoint
---@param b ncdk.MeasureTimePoint
---@return boolean
function MeasureTimePoint.__le(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at < bt or at == bt and a.visualSide <= b.visualSide
	end
	return at < bt or at == bt and a.side < b.side or at == bt and a.side == b.side and a.visualSide <= b.visualSide
end

return MeasureTimePoint
