local LayerData = require("ncdk.LayerData")
local TempoData = require("ncdk.TempoData")
local StopData = require("ncdk.StopData")
local Fraction = require("ncdk.Fraction")

--[[
	getAbsoluteTime is tested in base.lua
]]

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = LayerData:new()  -- signature = 4
	ld:setTimeMode("measure")

	ld:addTempoData(TempoData:new(F(-1), 120))
	ld:addTempoData(TempoData:new(F(0), 60))
	ld:addTempoData(TempoData:new(F(1), 30))

	assert(ld:getTempoDataDuration(1, F(-2), F(-1)) == 2)
	assert(ld:getTempoDataDuration(1, F(-1), F(0)) == 2)
	assert(ld:getTempoDataDuration(1, F(-1), F(1000)) == 2)

	assert(ld:getTempoDataDuration(2, F(-1000), F(1000)) == 4)
	assert(ld:getTempoDataDuration(2, F(0), F(1)) == 4)

	assert(ld:getTempoDataDuration(3, F(1), F(2)) == 8)
	assert(ld:getTempoDataDuration(3, F(2), F(3)) == 8)
	assert(ld:getTempoDataDuration(3, F(-1000), F(2)) == 8)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("measure")

	local tempoData = TempoData:new(F(0), 60)
	ld:addTempoData(tempoData)

	local stopData = StopData:new()
	stopData.time = F(0)
	stopData.duration = F(1)
	stopData.tempoData = tempoData
	stopData.signature = F(4)

	ld:addStopData(stopData)

	assert(ld:getStopDataDuration(1, F(-1000), F(1000), -1) == 4)
	assert(ld:getStopDataDuration(1, F(-1000), F(1000), 1) == 4)
	assert(ld:getStopDataDuration(1, F(100), F(1000), 1) == 0)
	assert(ld:getStopDataDuration(1, F(-1000), F(-100), 1) == 0)

	assert(ld:getStopDataDuration(1, F(-1), F(0), 1) == 4)
	assert(ld:getStopDataDuration(1, F(-1), F(0), -1) == 0)

	assert(ld:getStopDataDuration(1, F(0), F(1), -1) == 4)
	assert(ld:getStopDataDuration(1, F(0), F(1), 1) == 0)

	assert(ld:getAbsoluteDuration(F(0), F(1), 1, 1) == 4)
	assert(ld:getAbsoluteDuration(F(0), F(1), -1, 1) == 8)

	assert(ld:getAbsoluteDuration(F(-1), F(0), 1, -1) == 4)
	assert(ld:getAbsoluteDuration(F(-1), F(0), 1, 1) == 8)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("short")

	ld:addTempoData(TempoData:new(F(0), 60))
	ld:setSignature(0, F(8))

	assert(ld:getTempoDataDuration(1, F(-1), F(0)) == 4)
	assert(ld:getTempoDataDuration(1, F(0), F(1)) == 8)
	assert(ld:getTempoDataDuration(1, F(1), F(2)) == 4)
	assert(ld:getTempoDataDuration(1, F(0), F(2)) == 12)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")

	ld:addTempoData(TempoData:new(F(0), 60))
	ld:setSignature(0, F(8))

	assert(ld:getTempoDataDuration(1, F(-1), F(0)) == 4)
	assert(ld:getTempoDataDuration(1, F(0), F(1)) == 8)
	assert(ld:getTempoDataDuration(1, F(1), F(2)) == 8)
	assert(ld:getTempoDataDuration(1, F(0), F(2)) == 16)
end

do
	local ld = LayerData:new()
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
		assert(ld:getAbsoluteTime(_t[1], _t[2]) == _t[3])
	end
	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = LayerData:new()
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
		assert(ld:getAbsoluteTime(_t[1], _t[2]) == _t[3])
	end
	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = LayerData:new()
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
		assert(ld:getAbsoluteTime(_t[1], _t[2]) == _t[3])
	end
	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end
