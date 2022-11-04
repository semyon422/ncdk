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

	local stopData = StopData:new()
	stopData.measureTime = F(0)
	stopData.measureDuration = F(1)
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
