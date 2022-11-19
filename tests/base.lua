local ncdk = require("ncdk")
local NoteChart = require("ncdk.NoteChart")
local VelocityData = require("ncdk.VelocityData")
local StopData = require("ncdk.StopData")
local TempoData = require("ncdk.TempoData")
local NoteData = require("ncdk.NoteData")
local Fraction = require("ncdk.Fraction")

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local mt = Fraction:new(0)
	local tp = ld:getTimePoint(mt, 1)

	ld:insertTempoData(mt, 60)
	ld:insertVelocityData(mt, 1, 1)

	local nd = NoteData:new(tp)
	ld:addNoteData(nd)

	nc:compute()
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local mt = Fraction:new(0)
	local tp0 = ld:getTimePoint(mt, 1)

	ld:insertTempoData(mt, 60)

	ld:insertVelocityData(Fraction:new(-1), 1, 0.5)
	ld:insertVelocityData(Fraction:new(0), 1, 1)
	ld:insertVelocityData(Fraction:new(1), 1, 2)

	local cases = {
		{-2, 1, -1 * 4},
		{-1, 1, -1/2 * 4},
		{ 0, 1,  0 * 4},
		{ 1, 1,  1 * 4},
		{ 2, 1,  3 * 4},
	}
	for i, d in ipairs(cases) do
		d[4] = ld:getTimePoint(Fraction:new(d[1], d[2]), 1)
	end

	nc:compute()

	for i, d in ipairs(cases) do
		local tp = d[4]
		assert(
			tp.zeroClearVisualTime == d[3],
			"i: " .. i .. " vt1: " .. tp.zeroClearVisualTime .. " vt2: " .. d[3]
		)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local mt = Fraction:new(0)

	ld:insertTempoData(mt, 60)
	ld:insertVelocityData(mt, 1, 1)

	ld:insertStopData(Fraction:new(1), Fraction:new(4))
	ld:insertStopData(Fraction:new(2), Fraction:new(4))

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
			d[5].absoluteTime == d[3],
			"i: " .. i .. " vt1: " .. d[5].absoluteTime .. " vt2: " .. d[3]
		)
		assert(
			d[6].absoluteTime == d[4],
			"i: " .. i .. " vt1: " .. d[6].absoluteTime .. " vt2: " .. d[4]
		)
	end
end
