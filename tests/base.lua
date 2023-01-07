local NoteChart = require("ncdk.NoteChart")
local NoteData = require("ncdk.NoteData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local tp = ld:getTimePoint(F(0), 1)

	ld:insertTempoData(F(0), 60)
	ld:insertVelocityData(tp, 1)

	local nd = NoteData:new(tp)
	ld:addNoteData(nd)

	nc:compute()
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local mt = F(0)

	ld:insertTempoData(mt, 60)

	ld:insertVelocityData(ld:getTimePoint(F(-1)), 0.5)
	ld:insertVelocityData(ld:getTimePoint(F(0)), 1)
	ld:insertVelocityData(ld:getTimePoint(F(1)), 2)

	local cases = {
		{-2, -1 * 4},
		{-1, -1/2 * 4},
		{ 0,  0 * 4},
		{ 1,  1 * 4},
		{ 2,  3 * 4},
	}
	for i, d in ipairs(cases) do
		d[4] = ld:getTimePoint(F(d[1]))
	end

	nc:compute()

	for i, d in ipairs(cases) do
		local tp = d[4]
		assert(
			tp.visualTime == d[2],
			"i: " .. i .. " vt1: " .. tp.visualTime .. " vt2: " .. d[2]
		)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")

	local mt = F(0)

	ld:insertTempoData(mt, 60)
	ld:insertVelocityData(ld:getTimePoint(mt), 1)

	ld:insertStopData(F(1), F(4))
	ld:insertStopData(F(2), F(4))

	local cases = {
		{0, 0 * 4, 0 * 4},
		{1, 1 * 4, 2 * 4},
		{2, 3 * 4, 4 * 4},
		{3, 5 * 4, 5 * 4}
	}
	for i, d in ipairs(cases) do
		d[4] = ld:getTimePoint(F(d[1]), 0)
		d[5] = ld:getTimePoint(F(d[1]), 1)
	end

	nc:compute()

	for i, d in ipairs(cases) do
		assert(
			d[4].absoluteTime == d[2],
			"i: " .. i .. " vt1: " .. d[4].absoluteTime .. " vt2: " .. d[2]
		)
		assert(
			d[5].absoluteTime == d[3],
			"i: " .. i .. " vt1: " .. d[5].absoluteTime .. " vt2: " .. d[3]
		)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("short")

	local mt = Fraction:new(0)

	ld:insertTempoData(mt, 60)
	ld:setSignature(1, Fraction:new(8))
	ld:setSignature(3, Fraction:new(2))
	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(3))
	local tp4 = ld:getTimePoint(F(4))

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 12)
	assert(tp3.absoluteTime == 16)
	assert(tp4.absoluteTime == 18)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")

	local mt = Fraction:new(0)

	ld:insertTempoData(mt, 60)
	ld:setSignature(1, Fraction:new(8))
	ld:setSignature(3, Fraction:new(2))
	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(3))
	local tp4 = ld:getTimePoint(F(4))

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 12)
	assert(tp3.absoluteTime == 20)
	assert(tp4.absoluteTime == 22)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(F(0), 60)
	ld:insertTempoData(F(1), 120)

	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 6)

	assert(tp0.visualTime == 0)
	assert(tp1.visualTime == 4)
	assert(tp2.visualTime == 8)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")
	ld:setPrimaryTempo(60)

	ld:insertTempoData(0, 60)
	ld:insertTempoData(4, 120)

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(4)
	local tp2 = ld:getTimePoint(6)

	nc:compute()

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 6)

	assert(tp0.visualTime == 0)
	assert(tp1.visualTime == 4)
	assert(tp2.visualTime == 8)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("absolute")
	ld:setSignatureMode("long")

	local tp0 = ld:getTimePoint(0)
	local tp1 = ld:getTimePoint(4)
	local tp2 = ld:getTimePoint(8)

	local tps = {
		ld:newTimePoint():setTime(-1),
		ld:newTimePoint():setTime(0),
		ld:newTimePoint():setTime(2),
		ld:newTimePoint():setTime(4),
		ld:newTimePoint():setTime(5),
		ld:newTimePoint():setTime(8),
		ld:newTimePoint():setTime(9),
	}

	nc:compute()

	for i = 1, 3 do
		assert(ld:getBaseTimePoint(i, tps[1], "absolute") == 1)
		assert(ld:getBaseTimePoint(i, tps[2], "absolute") == 1)
		assert(ld:getBaseTimePoint(i, tps[3], "absolute") == 1)
		assert(ld:getBaseTimePoint(i, tps[4], "absolute") == 2)
		assert(ld:getBaseTimePoint(i, tps[5], "absolute") == 2)
		assert(ld:getBaseTimePoint(i, tps[6], "absolute") == 3)
		assert(ld:getBaseTimePoint(i, tps[7], "absolute") == 3)
	end
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("interval")

	local id1 = ld:insertIntervalData(-1, 11)
	local id2 = ld:insertIntervalData(10, 5)
	local id3 = ld:insertIntervalData(20, 1)

	local tp0 = ld:getTimePoint(id1, F(0))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp_1 = ld:getTimePoint(id1, F(-1))

	local tp11 = ld:getTimePoint(id2, F(1))
	local tp15 = ld:getTimePoint(id2, F(5))  -- not recommended here, not allowed in dynamic layer
	local tp16 = ld:getTimePoint(id2, F(6))
	local tp16_ = ld:getTimePoint(id3, F(1))

	nc:compute()

	assert(tp0.absoluteTime == -1)
	assert(tp1.absoluteTime == 0)
	assert(tp_1.absoluteTime == -2)
	assert(tp11.absoluteTime == 12)
	assert(tp15.absoluteTime == 20)
	assert(tp16.absoluteTime == 22)
	assert(tp16_.absoluteTime == 22)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("interval")

	local id1 = ld:insertIntervalData(0, 10)
	local id2 = ld:insertIntervalData(10, 1)

	local tp1 = ld:getTimePoint(id1, F(5))
	local tp2 = ld:getTimePoint(id1, F(5), 1)
	local tp3 = ld:getTimePoint(id1, F(5), 2)
	local tp4 = ld:getTimePoint(id1, F(5), 3)
	ld:insertExpandData(tp2, math.huge)

	nc:compute()

	assert(tp1:getVisualTime(id1.timePoint) == 5)
	assert(tp2:getVisualTime(id1.timePoint) == math.huge)
	assert(tp3:getVisualTime(id1.timePoint) == math.huge)
	assert(tp1:getVisualTime(id2.timePoint) == -math.huge)
	assert(tp2:getVisualTime(id2.timePoint) == 5)
	assert(tp3:getVisualTime(id2.timePoint) == 5)

	local tp = ld:newTimePoint()
	tp.absoluteTime = 5
	ld:interpolateTimePointAbsolute(1, tp, "absolute")
	assert(tp.visualTime == tp3.visualTime and tp.visualSection == tp3.visualSection)
	ld:interpolateTimePointAbsolute(100, tp, "absolute")
	assert(tp.visualTime == tp3.visualTime and tp.visualSection == tp3.visualSection)
end

do
	local nc = NoteChart:new()
	local ld = nc:getLayerData(1)
	ld:setTimeMode("interval")

	local id1 = ld:insertIntervalData(0, 10)
	local id2 = ld:insertIntervalData(10, 1)

	local tp1 = ld:getTimePoint(id1, F(0))

	nc:compute()

	assert(id1.timePoint == tp1)
	assert(id1.timePoint.ptr == tp1.ptr)
end
