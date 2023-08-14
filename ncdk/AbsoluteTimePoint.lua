local TimePoint = require("ncdk.TimePoint")

local AbsoluteTimePoint = TimePoint + {}

AbsoluteTimePoint.visualSide = 0

function AbsoluteTimePoint:setTime(time, visualSide)
	assert(type(time) == "number")
	self.absoluteTime = time
	self.visualSide = visualSide
	return self
end

AbsoluteTimePoint.setTimeAbsolute = AbsoluteTimePoint.setTime

function AbsoluteTimePoint:getTime()
	return self.absoluteTime, self.visualSide
end

function AbsoluteTimePoint:getPrevVisualTime()
	return self.absoluteTime, self.visualSide - 1
end

function AbsoluteTimePoint.__tostring(a)
	return ("(%s,%s)"):format(a:getAbsoluteTimeKey(), a.visualSide)
end

function AbsoluteTimePoint.__eq(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at == bt and a.visualSide == b.visualSide
end

function AbsoluteTimePoint.__lt(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at < bt or (at == bt and a.visualSide < b.visualSide)
end

function AbsoluteTimePoint.__le(a, b)
	local at, bt = a.absoluteTime, b.absoluteTime
	return at < bt or at == bt and a.visualSide <= b.visualSide
end

return AbsoluteTimePoint
