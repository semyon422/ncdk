local ncdk = require("ncdk")
local NoteChart = require("ncdk.NoteChart")
local VelocityData = require("ncdk.VelocityData")
local StopData = require("ncdk.StopData")
local TempoData = require("ncdk.TempoData")
local NoteData = require("ncdk.NoteData")
local Fraction = require("ncdk.Fraction")

do
	local nc = NoteChart:new()
	local ld = nc:requireLayerData(1)
	ld.timeData:setMode("measure")
	
	local mt = Fraction:new(0)
	local tp = ld:getTimePoint(mt)
	
	local td = TempoData:new(mt, 60)
	ld:addTempoData(td)
	
	local vd = VelocityData:new(tp, Fraction:new(1))
	ld:addVelocityData(vd)
	
	local nd = NoteData:new(tp)
	ld:addNoteData(nd)
	
	nc:compute()
end

do
	local nc = NoteChart:new()
	local ld = nc:requireLayerData(1)
	ld.timeData:setMode("measure")
	
	local mt = Fraction:new(0)
	local tp0 = ld:getTimePoint(mt)
	
	local td = TempoData:new(mt, 60)
	ld:addTempoData(td)
	
	local tp1 = ld:getTimePoint(Fraction:new(-1))
	local vd1 = VelocityData:new(tp1, Fraction:new(1, 2))
	ld:addVelocityData(vd1)
	
	local tp2 = ld:getTimePoint(Fraction:new(0))
	local vd2 = VelocityData:new(tp2, Fraction:new(1))
	ld:addVelocityData(vd2)
	
	local tp3 = ld:getTimePoint(Fraction:new(1))
	local vd3 = VelocityData:new(tp3, Fraction:new(2))
	ld:addVelocityData(vd3)
	
	-- -1	1/2
	-- 0	1
	-- 1	2
	
	local cases = {
		{-2, 1, -1 * 4},
		{-1, 1, -1/2 * 4},
		{ 0, 1,  0 * 4},
		{ 1, 1,  1 * 4},
		{ 2, 1,  3 * 4},
	}
	for i, d in ipairs(cases) do
		d[4] = ld:getTimePoint(Fraction:new(d[1], d[2]))
	end
	
	nc:compute()
	
	for i, d in ipairs(cases) do
		local tp = d[4]
		assert(
			tp.zeroClearVisualTime == ld:getVisualTime(tp, tp0, true),
			"i: " .. i .. " vt1: " .. tp.zeroClearVisualTime .. " vt2: " .. ld:getVisualTime(tp, tp0, true)
		)
		assert(
			tp.zeroClearVisualTime == d[3],
			"i: " .. i .. " vt1: " .. tp.zeroClearVisualTime .. " vt2: " .. d[3]
		)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:requireLayerData(1)
	ld.timeData:setMode("measure")
	
	local mt = Fraction:new(0)
	local tp0 = ld:getTimePoint(mt)
	
	local vd = VelocityData:new(tp0, Fraction:new(1))
	ld:addVelocityData(vd)
	
	local td1 = TempoData:new(Fraction:new(-1), 120)
	ld:addTempoData(td1)
	
	local td2 = TempoData:new(Fraction:new(0), 60)
	ld:addTempoData(td2)
	
	local td3 = TempoData:new(Fraction:new(1), 30)
	ld:addTempoData(td3)
	
	-- -1	120
	-- 0	60
	-- 1	30
	
	local cases = {
		{-2, 1, -1 * 4},
		{-1, 1, -1/2 * 4},
		{ 0, 1,  0 * 4},
		{ 1, 1,  1 * 4},
		{ 2, 1,  3 * 4},
	}
	for i, d in ipairs(cases) do
		d[4] = ld:getTimePoint(Fraction:new(d[1], d[2]))
	end
	
	nc:compute()
	
	for i, d in ipairs(cases) do
		assert(
			d[3] == ld.timeData:getAbsoluteTime(d[4].measureTime, -1),
			"i: " .. i .. " vt1: " .. d[3] .. " vt2: " .. ld.timeData:getAbsoluteTime(d[4].measureTime, -1)
		)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:requireLayerData(1)
	ld.timeData:setMode("measure")
	
	local mt = Fraction:new(0)
	local tp = ld:getTimePoint(mt)
	
	local vd = VelocityData:new(tp, Fraction:new(1))
	ld:addVelocityData(vd)
	
	local td = TempoData:new(mt, 60)
	ld:addTempoData(td)
	
	local sd1 = StopData:new()
	sd1.measureTime = Fraction:new(1)
	sd1.measureDuration = Fraction:new(1)
	sd1.tempoData = td
	sd1.signature = Fraction:new(4)
	ld:addStopData(sd1)
	
	local sd2 = StopData:new()
	sd2.measureTime = Fraction:new(2)
	sd2.measureDuration = Fraction:new(1)
	sd2.tempoData = td
	sd2.signature = Fraction:new(4)
	ld:addStopData(sd2)
	
	-- 1	1
	-- 2	1
	
	local cases = {
		{0, 1, 0 * 4, 0 * 4},
		{1, 1, 1 * 4, 2 * 4},
		{2, 1, 3 * 4, 4 * 4},
		{3, 1, 5 * 4, 5 * 4}
	}
	for i, d in ipairs(cases) do
		d[5] = ld:getTimePoint(Fraction:new(d[1], d[2]), -1)
		d[6] = ld:getTimePoint(Fraction:new(d[1], d[2]), 1)
	end
	
	nc:compute()
	
	for i, d in ipairs(cases) do
		assert(
			d[3] == ld.timeData:getAbsoluteTime(d[5].measureTime, -1),
			"i: " .. i .. " vt1: " .. d[3] .. " vt2: " .. ld.timeData:getAbsoluteTime(d[5].measureTime, -1)
		)
		assert(
			d[4] == ld.timeData:getAbsoluteTime(d[6].measureTime, 1),
			"i: " .. i .. " vt1: " .. d[4] .. " vt2: " .. ld.timeData:getAbsoluteTime(d[6].measureTime, 1)
		)
		assert(
			d[5].absoluteTime == d[3],
			"i: " .. i .. " vt1: " .. d[5].absoluteTime .. " vt2: " .. d[3]
		)
		assert(
			d[6].absoluteTime == d[4],
			"i: " .. i .. " vt1: " .. d[6].absoluteTime .. " vt2: " .. d[4]
		)
	end
end
