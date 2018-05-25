ncdk.TimePoint = {}
local TimePoint = ncdk.TimePoint

ncdk.TimePoint_metatable = {}
local TimePoint_metatable = ncdk.TimePoint_metatable
TimePoint_metatable.__index = TimePoint

TimePoint.new = function(self)
	local timePoint = {}
	
	setmetatable(timePoint, TimePoint_metatable)
	
	return timePoint
end

TimePoint.getAbsoluteTime = function(self)
	return self.absoluteTime
end

TimePoint_metatable.__eq = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime == tpb.measureTime and tpa.side == tpb.side
	else
		return tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side
	end
end

TimePoint_metatable.__lt = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime < tpb.measureTime or (tpa.measureTime == tpb.measureTime and tpa.side < tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side < tpb.side)
	end
end

TimePoint_metatable.__le = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime < tpb.measureTime or (tpa.measureTime == tpb.measureTime and tpa.side == tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side)
	end
end