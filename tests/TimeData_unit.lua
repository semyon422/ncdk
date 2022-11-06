local TimeData = require("ncdk.TimeData")
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
	local td = TimeData:new()  -- signature = 4
	td:setMode("measure")

	td:addTempoData(TempoData:new(F(-1), 120))
	td:addTempoData(TempoData:new(F(0), 60))
	td:addTempoData(TempoData:new(F(1), 30))

	assert(td:getTempoDataDuration(1, F(-2), F(-1)) == 2)
	assert(td:getTempoDataDuration(1, F(-1), F(0)) == 2)
	assert(td:getTempoDataDuration(1, F(-1), F(1000)) == 2)

	assert(td:getTempoDataDuration(2, F(-1000), F(1000)) == 4)
	assert(td:getTempoDataDuration(2, F(0), F(1)) == 4)

	assert(td:getTempoDataDuration(3, F(1), F(2)) == 8)
	assert(td:getTempoDataDuration(3, F(2), F(3)) == 8)
	assert(td:getTempoDataDuration(3, F(-1000), F(2)) == 8)
end

do
	local td = TimeData:new()
	td:setMode("measure")

	local tempoData = TempoData:new(F(0), 60)
	td:addTempoData(tempoData)

	local stopData = StopData:new()
	stopData.time = F(0)
	stopData.duration = F(1)
	stopData.tempoData = tempoData
	stopData.signature = F(4)

	td:addStopData(stopData)

	assert(td:getStopDataDuration(1, F(-1000), F(1000), -1) == 4)
	assert(td:getStopDataDuration(1, F(-1000), F(1000), 1) == 4)
	assert(td:getStopDataDuration(1, F(100), F(1000), 1) == 0)
	assert(td:getStopDataDuration(1, F(-1000), F(-100), 1) == 0)

	assert(td:getStopDataDuration(1, F(-1), F(0), 1) == 4)
	assert(td:getStopDataDuration(1, F(-1), F(0), -1) == 0)

	assert(td:getStopDataDuration(1, F(0), F(1), -1) == 4)
	assert(td:getStopDataDuration(1, F(0), F(1), 1) == 0)

	assert(td:getAbsoluteDuration(F(0), F(1), 1, 1) == 4)
	assert(td:getAbsoluteDuration(F(0), F(1), -1, 1) == 8)

	assert(td:getAbsoluteDuration(F(-1), F(0), 1, -1) == 4)
	assert(td:getAbsoluteDuration(F(-1), F(0), 1, 1) == 8)
end

do
	local td = TimeData:new()
	td:setMode("measure")
	td:setSignatureMode("short")

	td:addTempoData(TempoData:new(F(0), 60))
	td:setSignature(0, F(8))

	assert(td:getTempoDataDuration(1, F(-1), F(0)) == 4)
	assert(td:getTempoDataDuration(1, F(0), F(1)) == 8)
	assert(td:getTempoDataDuration(1, F(1), F(2)) == 4)
	assert(td:getTempoDataDuration(1, F(0), F(2)) == 12)
end

do
	local td = TimeData:new()
	td:setMode("measure")
	td:setSignatureMode("long")

	td:addTempoData(TempoData:new(F(0), 60))
	td:setSignature(0, F(8))

	assert(td:getTempoDataDuration(1, F(-1), F(0)) == 4)
	assert(td:getTempoDataDuration(1, F(0), F(1)) == 8)
	assert(td:getTempoDataDuration(1, F(1), F(2)) == 8)
	assert(td:getTempoDataDuration(1, F(0), F(2)) == 16)
end

do
	local td = TimeData:new()
	td:setMode("measure")

	td:addTempoData(TempoData:new(F(0.5), 60))
	td:addTempoData(TempoData:new(F(1.5), 120))
	td:addTempoData(TempoData:new(F(2.5), 240))

	local stopData = StopData:new()
	stopData.time = F(-2.5)
	stopData.duration = F(1)
	stopData.tempoData = TempoData:new(F(0.5), 60)
	stopData.signature = F(4)
	td:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(-1)
	stopData.duration = F(2)
	stopData.tempoData = TempoData:new(F(0.5), 60)
	stopData.signature = F(4)
	td:addStopData(stopData)

	local stopData = StopData:new()
	stopData.time = F(1.5)
	stopData.duration = F(0.5)
	stopData.tempoData = TempoData:new(F(1.5), 120)
	stopData.signature = F(4)
	td:addStopData(stopData)

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
		assert(td:getAbsoluteTime(_t[1], _t[2]) == _t[3])
	end
	for _, _t in ipairs(t) do
		td:getTimePoint(_t[1], _t[2])
	end
	td:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(td:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end
