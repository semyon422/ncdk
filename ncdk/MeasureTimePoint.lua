local TimePoint = require("ncdk.TimePoint")

local MeasureTimePoint = TimePoint:new()

MeasureTimePoint.side = -1
MeasureTimePoint.visualSide = -1

function MeasureTimePoint:setTime(time, side, visualSide)
	self.measureTime = time
	self.side = side
	self.visualSide = visualSide
end

function MeasureTimePoint:setTimeAbsolute(time, side, visualSide)
	self.absoluteTime = time
	self.side = side
	self.visualSide = visualSide
end

function MeasureTimePoint:getTime()
	return self.measureTime, self.side, self.visualSide
end

function MeasureTimePoint:getKey()
	return self.measureTime .. "," .. self.side .. "," .. self.visualSide
end

function MeasureTimePoint:tonumber()
	return self.measureTime:tonumber()
end

function MeasureTimePoint.__tostring(a)
	return ("%s%s%s"):format(a.measureTime, a.side == -1 and "<-" or "->", a.visualSide == -1 and "<-" or "->")
end

local function getTimes(a, b)
	if a.measureTime and b.measureTime then
		return a.measureTime, b.measureTime
	end
	return a.absoluteTime, b.absoluteTime
end

function MeasureTimePoint.__eq(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at == bt and a.visualSide == b.visualSide
	end
	return at == bt and a.side == b.side and a.visualSide == b.visualSide
end

function MeasureTimePoint.__lt(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at < bt or (at == bt and a.visualSide < b.visualSide)
	end
	return at < bt or at == bt and a.side < b.side or at == bt and a.side == b.side and a.visualSide < b.visualSide
end

function MeasureTimePoint.__le(a, b)
	local at, bt = getTimes(a, b)
	if type(at) == "number" then
		return at < bt or at == bt and a.visualSide <= b.visualSide
	end
	return at < bt or at == bt and a.side < b.side or at == bt and a.side == b.side and a.visualSide <= b.visualSide
end

return MeasureTimePoint
