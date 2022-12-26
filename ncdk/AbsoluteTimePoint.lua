local TimePoint = require("ncdk.TimePoint")

local AbsoluteTimePoint = TimePoint:new()

AbsoluteTimePoint.visualSide = -1

function AbsoluteTimePoint:setTime(time, visualSide)
	self.absoluteTime = time
	self.visualSide = visualSide
end

function AbsoluteTimePoint:getTime()
	return self.absoluteTime, self.visualSide
end

function AbsoluteTimePoint:getKey()
	return self.absoluteTime .. "," .. self.visualSide
end

function AbsoluteTimePoint.__tostring(a)
	return ("%s%s%s"):format(a.absoluteTime, a.visualSide == -1 and "<-" or "->")
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
