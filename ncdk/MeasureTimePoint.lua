local TimePoint = require("ncdk.TimePoint")

local MeasureTimePoint = TimePoint:new()

MeasureTimePoint.side = 0
MeasureTimePoint.visualSide = 0

function MeasureTimePoint:setTime(time, side, visualSide)
	assert(type(time) == "table")
	self.measureTime = time
	self.side = side
	self.visualSide = visualSide
	return self
end

function MeasureTimePoint:setTimeAbsolute(time, visualSide)
	assert(type(time) == "number")
	self.measureTime = nil
	self.absoluteTime = time
	self.side = nil
	self.visualSide = visualSide
	return self
end

function MeasureTimePoint:getTime()
	return self.measureTime, self.side, self.visualSide
end

function MeasureTimePoint:getPrevTime()
	return self.measureTime, self.side - 1, 0
end

function MeasureTimePoint:getPrevVisualTime()
	return self.measureTime, self.side, self.visualSide - 1
end

function MeasureTimePoint:tonumber()
	return self.measureTime:tonumber()
end

function MeasureTimePoint.__tostring(a)
	if a.measureTime then
		return ("(%s,%s,%s)"):format(a.measureTime, a.side, a.visualSide)
	end
	return ("(A%s,%s,%s)"):format(a.absoluteTime, a.side, a.visualSide)
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
