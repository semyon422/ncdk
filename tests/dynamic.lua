local DynamicLayerData = require("ncdk.DynamicLayerData")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local VelocityData = require("ncdk.VelocityData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")

	ld:addTempoData(TempoData:new(F(0), 60))

	local timePoints = {
		ld:getTimePoint(F(-1), -1),
		ld:getTimePoint(F(1), -1),
		ld:getTimePoint(F(2), -1),
		ld:getTimePoint(F(3), -1),
		ld:getTimePoint(F(4), -1),
		ld:getTimePoint(F(5), -1),
		ld:getTimePoint(F(6), -1),
		ld:getTimePoint(F(7), -1),
	}

	ld:compute()
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")

	ld:addTempoData(TempoData:new(F(0), 60))

	local stopData = StopData:new()
	stopData.time = F(1)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(2)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local t = {
		{F(0), -1, 0},
		{F(1), -1, 4},
		{F(1), 1, 8},
		{F(2), -1, 12},
		{F(2), 1, 16},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:compute()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")

	ld:addTempoData(TempoData:new(F(0), 60))

	local stopData = StopData:new()
	stopData.time = F(-1)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(1)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local t = {
		{F(-2), -1, -12},
		{F(-1), -1, -8},
		{F(-1), 1, -4},
		{F(0), -1, 0},
		{F(0.5), 1, 2},
		{F(1), -1, 4},
		{F(1), 1, 8},
		{F(2), -1, 12},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:compute()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")

	ld:addTempoData(TempoData:new(F(0.5), 60))
	ld:addTempoData(TempoData:new(F(1.5), 120))
	ld:addTempoData(TempoData:new(F(2.5), 240))

	local stopData = StopData:new()
	stopData.time = F(-2.5)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0.5), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(-1)
	stopData.duration = F(2)
	stopData.tempoData = TempoData:new(F(0.5), 60)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(1.5)
	stopData.duration = F(0.5)
	stopData.tempoData = TempoData:new(F(1.5), 120)
	stopData.signature = F(4)
	ld:addStopData(stopData)

	local t = {
		{F(-3), -1, -24},
		{F(-2.5), -1, -22},
		{F(-2.5), 1, -18},
		{F(-2), -1, -16},
		{F(-1), -1, -12},
		{F(-1), 1, -4},
		{F(0), -1, 0},
		{F(0.5), -1, 2},
		{F(1), -1, 4},
		{F(1.5), -1, 6},
		{F(1.5), 1, 7},
		{F(2), -1, 8},
		{F(2.5), -1, 9},
		{F(3), -1, 9.5},
		{F(3.5), -1, 10},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:compute()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:addTempoData(TempoData:new(F(0), 60))

	local tp4 = ld:getTimePoint(Fraction:new(-1), -1)
	local tp1 = ld:getTimePoint(Fraction:new(0), -1)
	local tp2 = ld:getTimePoint(Fraction:new(1), -1)
	local tp3 = ld:getTimePoint(Fraction:new(2), -1)

	local vd = VelocityData:new(tp1)
	vd.currentSpeed = 1
	ld:addVelocityData(vd)

	vd = VelocityData:new(tp2)
	vd.currentSpeed = 2
	ld:addVelocityData(vd)

	ld:compute()

	assert(tp2.zeroClearVisualTime == tp1.absoluteTime + 4)
	assert(tp3.zeroClearVisualTime == tp2.absoluteTime + 8)
	assert(tp3.zeroClearVisualTime == tp1.absoluteTime + 12)
	assert(tp4.zeroClearVisualTime == tp1.absoluteTime - 4)
end
