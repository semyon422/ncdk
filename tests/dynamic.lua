local DynamicLayerData = require("ncdk.DynamicLayerData")
local LayerData = require("ncdk.LayerData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)

	local tp = ld:getTimePoint(F(0))
	assert(tp.absoluteTime == 0)

	tp = ld:getTimePoint(F(1))
	assert(tp.absoluteTime == 4)

	tp = ld:getTimePoint(F(-1))
	assert(tp.absoluteTime == -4)

	ld:getTimePoint(F(-10))
	ld:getTimePoint(F(-9))
	ld:getTimePoint(F(-8))
	ld:getTimePoint(F(-7))
	ld:getTimePoint(F(10))
	ld:getTimePoint(F(9))
	ld:getTimePoint(F(8))
	ld:getTimePoint(F(7))

	ld:setRange(F(-8), F(-5))

	tp = ld:getTimePoint(F(-7))
	assert(tp.absoluteTime == -28)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)

	assert(ld:getTimePoint(F(0)).absoluteTime == 0)
	assert(ld:getTimePoint(F(1)).absoluteTime == 4)

	ld:getTempoData(F(1), 120)
	assert(ld:getTimePoint(F(2)).absoluteTime == 6)

	ld:getTempoData(F(2), 240)
	assert(ld:getTimePoint(F(3)).absoluteTime == 7)

	ld:getTempoData(F(-1), 30)
	assert(ld:getTimePoint(F(-1)).absoluteTime == -8)

	ld:getTempoData(F(-2), 15)
	assert(ld:getTimePoint(F(-2)).absoluteTime == -24)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(2))

	ld:getTempoData(F(0), 60)

	assert(ld:getTimePoint(F(1)).absoluteTime == 4)

	ld:setRange(F(4), F(8))
	assert(ld:getTimePoint(F(4)).absoluteTime == 16)
	assert(ld:getTimePoint(F(5)).absoluteTime == 20)
	assert(ld:getTimePoint(F(6)).absoluteTime == 24)
	assert(ld:getTimePoint(F(7)).absoluteTime == 28)
	assert(ld:getTimePoint(F(8)).absoluteTime == 32)
	ld:setRange(F(4), F(6))

	assert(ld.ranges.timePoint.head == ld:getTimePoint(F(1)))
	assert(ld.ranges.timePoint.tail == ld:getTimePoint(F(7)))
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	local timePoints = {}
	for i = 0, 10 do
		timePoints[i] = ld:getTimePoint(F(i))
	end

	ld:setRange(F(0), F(2))

	assert(timePoints[2].absoluteTime == 8)
	assert(timePoints[3].absoluteTime == 12)
	assert(timePoints[4].absoluteTime == 16)
	assert(timePoints[5].absoluteTime == 20)

	ld:getTempoData(F(0), 120)

	assert(timePoints[2].absoluteTime == 4)
	assert(timePoints[3].absoluteTime == 6)
	assert(timePoints[4].absoluteTime == 16)
	assert(timePoints[5].absoluteTime == 20)

	ld:setRange(F(5), F(7))

	assert(timePoints[2].absoluteTime == 4)
	assert(timePoints[3].absoluteTime == 6)
	assert(timePoints[4].absoluteTime == 8)
	assert(timePoints[5].absoluteTime == 10)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	for i = 0, 10 do
		ld:getTimePoint(F(i))
	end

	assert(ld:getTimePoint(F(0)).absoluteTime == 0)
	assert(ld:getTimePoint(F(1)).absoluteTime == 4)
	assert(ld:getTimePoint(F(2)).absoluteTime == 8)
	assert(ld:getTimePoint(F(3)).absoluteTime == 12)

	ld:getTempoData(F(1), 120)

	assert(ld:getTimePoint(F(0)).absoluteTime == 0)
	assert(ld:getTimePoint(F(1)).absoluteTime == 4)
	assert(ld:getTimePoint(F(2)).absoluteTime == 6)
	assert(ld:getTimePoint(F(3)).absoluteTime == 8)

	ld:removeTempoData(F(0))

	assert(ld:getTimePoint(F(0)).absoluteTime == 0)
	assert(ld:getTimePoint(F(1)).absoluteTime == 2)
	assert(ld:getTimePoint(F(2)).absoluteTime == 4)
	assert(ld:getTimePoint(F(3)).absoluteTime == 6)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	local timePoints = {}
	for i = 0, 10 do
		timePoints[i] = ld:getTimePoint(F(i))
	end

	assert(timePoints[0].absoluteTime == 0)
	assert(timePoints[1].absoluteTime == 4)
	assert(timePoints[9].absoluteTime == 36)
	assert(timePoints[10].absoluteTime == 40)

	ld:setRange(F(0), F(0))

	ld:getTempoData(F(0), 120)

	assert(timePoints[0].absoluteTime == 0)
	assert(timePoints[1].absoluteTime == 2)
	assert(timePoints[9].absoluteTime == 36)
	assert(timePoints[10].absoluteTime == 40)

	ld:setRange(F(10), F(10))

	assert(timePoints[0].absoluteTime == 0)
	assert(timePoints[1].absoluteTime == 2)
	assert(timePoints[9].absoluteTime == 18)
	assert(timePoints[10].absoluteTime == 20)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)
	ld:getStopData(F(1), F(4))
	ld:getStopData(F(2), F(4))

	local t = {
		{F(0), 0, 0},
		{F(1), 0, 4},
		{F(1), 1, 8},
		{F(2), 0, 12},
		{F(2), 1, 16},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)
	ld:getStopData(F(-1), F(4))
	ld:getStopData(F(1), F(4))

	local t = {
		{F(-2), 0, -12},
		{F(-1), 0, -8},
		{F(-1), 1, -4},
		{F(0), 0, 0},
		{F(0.5), 1, 2},
		{F(1), 0, 4},
		{F(1), 1, 8},
		{F(2), 0, 12},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0.5), 60)
	ld:getTempoData(F(1.5), 120)
	ld:getTempoData(F(2.5), 240)

	ld:getStopData(F(-2.5), F(4))
	ld:getStopData(F(-1), F(8))
	ld:getStopData(F(1.5), F(2))

	local t = {
		{F(-3), 0, -24},
		{F(-2.5), 0, -22},
		{F(-2.5), 1, -18},
		{F(-2), 0, -16},
		{F(-1), 0, -12},
		{F(-1), 1, -4},
		{F(0), 0, 0},
		{F(0.5), 1, 2},  -- right time point only
		{F(1), 0, 4},
		{F(1.5), 0, 6},
		{F(1.5), 1, 7},
		{F(2), 0, 8},
		{F(2.5), 0, 9},
		{F(3), 0, 9.5},
		{F(3.5), 0, 10},
	}

	for _, _t in ipairs(t) do
		ld:getTimePoint(_t[1], _t[2])
	end
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end

	ld:removeStopData(F(-1))

	local t = {
		{F(-3), 0, -16},
		{F(-2.5), 0, -14},
		{F(-2.5), 1, -10},
		{F(-2), 0, -8},
		{F(-1), 0, -4},
		{F(-1), 1, -4},
		{F(0), 0, 0},
		{F(0.5), 0, 2},
		{F(1), 0, 4},
	}

	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	local tp4 = ld:getTimePoint(F(-1))
	local tp1 = ld:getTimePoint(F(0))
	local tp2 = ld:getTimePoint(F(1))
	local tp3 = ld:getTimePoint(F(2))

	ld:getVelocityData(tp1, 1)
	ld:getVelocityData(tp2, 2)

	assert(tp2.visualTime == tp1.absoluteTime + 4)
	assert(tp3.visualTime == tp2.absoluteTime + 8)
	assert(tp3.visualTime == tp1.absoluteTime + 12)
	assert(tp4.visualTime == tp1.absoluteTime - 4)

	ld:removeVelocityData(tp1)

	assert(tp2.visualTime == 8)
	assert(tp3.visualTime == 16)
	assert(tp4.visualTime == -8)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	local tp1 = ld:getTimePoint(F(0))
	local tp2 = ld:getTimePoint(F(1))
	local tp3 = ld:getTimePoint(F(2))

	local nd1 = ld:getNoteData(tp1, "key", 1)
	local nd2 = ld:getNoteData(tp2, "key", 2)
	local nd3 = ld:getNoteData(tp3, "key", 3)

	ld:removeNoteData(nd2)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	local tp1 = ld:getTimePoint(F(0))
	local tp2 = ld:getTimePoint(F(1))
	local tp3 = ld:getTimePoint(F(2))

	local dtp = ld:getDynamicTimePoint(F(0.5))
	assert(dtp.absoluteTime == 2)
	assert(dtp.visualTime == 2)

	dtp = ld:getDynamicTimePoint(F(-1))
	assert(dtp.absoluteTime == -4)
	assert(dtp.visualTime == -4)

	dtp = ld:getDynamicTimePoint(F(3.5))
	assert(dtp.absoluteTime == 14)
	assert(dtp.visualTime == 14)

	ld:getStopData(F(1), F(4))
	dtp = ld:getDynamicTimePoint(F(1))
	assert(dtp.absoluteTime == 4)
	assert(dtp.visualTime == 4)
	dtp = ld:getDynamicTimePoint(F(1), 1)
	assert(dtp.absoluteTime == 8)
	assert(dtp.visualTime == 8)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	ld:getExpandData(ld:getTimePoint(F(1), 0, 1), F(1))

	assert(ld:getTimePoint(F(1), 0, 0).visualTime == 4)
	assert(ld:getTimePoint(F(1), 0, 1).visualTime == 5)

	ld:removeExpandData(ld:getTimePoint(F(1), 0, 1))

	assert(ld:getTimePoint(F(1), 0, 0).visualTime == 4)
	assert(ld:getTimePoint(F(1), 0, 1).visualTime == 4)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(Fraction(0), Fraction(10))

	ld:getTempoData(Fraction(1), 60)
	ld:getTempoData(Fraction(3, 10, true), 120)

	local function dat(t)
		return ld:getDynamicTimePoint(Fraction(t)).absoluteTime
	end

	assert(dat(1) == 4)
	assert(dat(2) == 8)
	assert(dat(3) == 12)
	assert(dat(4) == 14)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(Fraction(0), Fraction(10))

	local mt = Fraction:new(0)

	ld:getTempoData(mt, 60)
	ld:getSignatureData(1, Fraction:new(8))
	ld:getSignatureData(3, Fraction:new(2))
	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(3))
	local tp4 = ld:getTimePoint(F(4))

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 12)
	assert(tp3.absoluteTime == 16)
	assert(tp4.absoluteTime == 18)

	ld:setRange(Fraction(5), Fraction(10))
	assert(ld:getTimePoint(F(5)).absoluteTime == 22)
	assert(ld:getTimePoint(F(6)).absoluteTime == 26)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(Fraction(0), Fraction(10))

	local mt = Fraction:new(0)

	ld:getTempoData(mt, 60)
	ld:getSignatureData(2, Fraction:new(2))

	assert(ld:getDynamicTimePoint(F(2)).absoluteTime == 8)
	assert(ld:getDynamicTimePoint(F(3)).absoluteTime == 10)
	assert(ld:getDynamicTimePoint(F(4)).absoluteTime == 14)

	ld:setSignatureMode("long")

	assert(ld:getDynamicTimePoint(F(4)).absoluteTime == 12)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setRange(Fraction(0), Fraction(10))

	local mt = Fraction:new(0)

	ld:getTempoData(mt, 60)
	ld:getSignatureData(1, Fraction:new(8))
	ld:getSignatureData(3, Fraction:new(2))
	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp2 = ld:getTimePoint(F(2))
	local tp3 = ld:getTimePoint(F(3))
	local tp4 = ld:getTimePoint(F(4))

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 4)
	assert(tp2.absoluteTime == 12)
	assert(tp3.absoluteTime == 20)
	assert(tp4.absoluteTime == 22)

	ld:setRange(Fraction(5), Fraction(10))
	assert(ld:getTimePoint(F(5)).absoluteTime == 24)
	assert(ld:getTimePoint(F(6)).absoluteTime == 26)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("long")
	ld:setRange(Fraction(0), Fraction(1))

	ld:getTempoData(F(0), 60)

	ld:getTimePoint(F(0))
	ld:getTimePoint(F(1))

	local function geta(t)
		return ld:getDynamicTimePointAbsolute(192, t)
	end

	assert(geta(0).measureTime == F(0))
	assert(geta(2).measureTime == F(0.5))
	assert(geta(4).measureTime == F(1))
	assert(geta(8).measureTime == F(2))
	assert(geta(-4).measureTime == F(-1))

	assert(geta(0).visualTime == 0)
	assert(geta(2).visualTime == 2)
	assert(geta(4).visualTime == 4)
	assert(geta(8).visualTime == 8)
	assert(geta(-4).visualTime == -4)

	local function get(t)
		return ld:getDynamicTimePoint(F(t))
	end

	assert(get(0).absoluteTime == 0)
	assert(get(0.5).absoluteTime == 2)
	assert(get(1).absoluteTime == 4)
	assert(get(2).absoluteTime == 8)
	assert(get(-1).absoluteTime == -4)

	assert(get(0).visualTime == 0)
	assert(get(0.5).visualTime == 2)
	assert(get(1).visualTime == 4)
	assert(get(2).visualTime == 8)
	assert(get(-1).visualTime == -4)
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(0), F(10))

	ld:getSignatureData(2, F(3))

	ld:getTempoData(F(1), 60)
	ld:getTempoData(F(3.5), 120)

	ld:getStopData(F(5), F(4))

	ld:getVelocityData(ld:getTimePoint(F(0.5)), 1)
	ld:getVelocityData(ld:getTimePoint(F(4.5)), 2)
	ld:getVelocityData(ld:getTimePoint(F(5 / 4)), 0)
	ld:getVelocityData(ld:getTimePoint(F(6 / 4)), 1)

	ld:getExpandData(ld:getTimePoint(F(2), 0, 1), F(1))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(192, 32)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(192, 32)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(192, 32)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(3), F(13))
	local dtp = ld:getDynamicTimePointAbsolute(192, 24)
	assert(dtp.measureTime == F(8))

	ld:setRange(F(2), F(12))
	assert(ld:getDynamicTimePointAbsolute(192, 22))
	assert(ld:getDynamicTimePoint(Fraction(2)))
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(1), 60)

	ld:getStopData(F(5), F(1))
	ld:getExpandData(ld:getTimePoint(F(5), 1, 1), F(1))
	ld:getExpandData(ld:getTimePoint(F(5), 0, 1), F(1))

	assert(tostring(ld:getDynamicTimePoint(F(5))) == "(5.0/1,0,0)")  -- 20, 20
	assert(tostring(ld:getDynamicTimePoint(F(5), 0, 0)) == "(5.0/1,0,0)")  -- 20, 20
	assert(tostring(ld:getDynamicTimePoint(F(5), 0, 1)) == "(5.0/1,0,1)")  -- 20, 21
	assert(tostring(ld:getDynamicTimePoint(F(5), 1, 0)) == "(5.0/1,1,0)")  -- 21, 22
	assert(tostring(ld:getDynamicTimePoint(F(5), 1, 1)) == "(5.0/1,1,1)")  -- 21, 23

	assert(tostring(ld:getDynamicTimePointAbsolute(192, 20, 0)) == "(5.0/1,0,0)")
	assert(tostring(ld:getDynamicTimePointAbsolute(192, 20, 1)) == "(5.0/1,0,1)")
	assert(tostring(ld:getDynamicTimePointAbsolute(192, 21, 0)) == "(5.0/1,1,0)")
	assert(tostring(ld:getDynamicTimePointAbsolute(192, 21, 1)) == "(5.0/1,1,1)")
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("interval")
	ld:setRange(-10, 20)

	local id = ld:getIntervalData(0, F(10))
	ld:getIntervalData(10, F(1))

	ld:getExpandData(ld:getTimePoint(id, F(5), 1), F(1))

	assert(tostring(ld:getDynamicTimePoint(id, F(5))) == "(0,10.0/1,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePoint(id, F(5), 0)) == "(0,10.0/1,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePoint(id, F(5), 1)) == "(0,10.0/1,5.0/1,1)")

	assert(tostring(ld:getDynamicTimePointAbsolute(192, 5, 0)) == "(0,10.0/1,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePointAbsolute(192, 5, 1)) == "(0,10.0/1,5.0/1,1)")
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(-10), F(10))

	ld:getSignatureData(2, F(3))

	ld:getTempoData(F(1), 60)

	ld:getTimePoint(F(0))

	ld:getTimePoint(F(-5), 0, 0)
	ld:getTimePoint(F(-5), 0, 1)
	ld:getTimePoint(F(-5), 1, 0)
	ld:getTimePoint(F(-5), 1, 1)
	ld:getTimePoint(F(5), 0, 0)
	ld:getTimePoint(F(5), 0, 1)
	ld:getTimePoint(F(5), 1, 0)
	ld:getTimePoint(F(5), 1, 1)

	local range = ld.ranges.timePoint

	assert(tostring(range.head) == "(-5.0/1,0,0)")
	assert(tostring(range.tail) == "(5.0/1,1,1)")

	ld:getTimePoint(F(-10))
	ld:getTimePoint(F(10))

	ld:setRange(F(-3), F(3))
	assert(tostring(range.head) == "(-5.0/1,1,1)")
	assert(tostring(range.tail) == "(5.0/1,0,0)")

	ld:setRange(F(-5), F(5))
	assert(tostring(range.head) == "(-10.0/1,0,0)")
	assert(tostring(range.tail) == "(10.0/1,0,0)")
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)

	assert(ld:getTimePoint(F(1)).beatTime == 4)
	assert(ld:getTimePoint(F(-1)).beatTime == -4)
	assert(ld:getTimePoint(F(2)).beatTime == 8)

	ld:getSignatureData(2, F(3))

	assert(ld:getTimePoint(F(3)).beatTime == 11)
	assert(ld:getTimePoint(F(4)).beatTime == 15)

	ld:getSignatureData(-2, F(3))

	assert(ld:getTimePoint(F(-2)).beatTime == -7)
	assert(ld:getTimePoint(F(-3)).beatTime == -11)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(-1, F(11))
	local id2 = ld:getIntervalData(10, F(5))
	local id3 = ld:getIntervalData(20, F(1))

	local tp0 = ld:getTimePoint(id1, F(0))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp_1 = ld:getTimePoint(id1, F(-1))

	local tp11 = ld:getTimePoint(id2, F(1))
	-- local tp15 = ld:getTimePoint(id2, F(5))  -- not allowed
	-- local tp16 = ld:getTimePoint(id2, F(6))
	local tp16_ = ld:getTimePoint(id3, F(1))
	local tp17 = ld:getTimePoint(id3, F(2))

	assert(tp0.absoluteTime == -1)
	assert(tp1.absoluteTime == 0)
	assert(tp_1.absoluteTime == -2)
	assert(tp11.absoluteTime == 12)
	-- assert(tp15.absoluteTime == 20)
	-- assert(tp16.absoluteTime == 22)
	assert(tp16_.absoluteTime == 22)
	assert(tp17.absoluteTime == 24)

	assert(ld:getDynamicTimePoint(id1, F(-2)).absoluteTime == -3)
	assert(ld:getDynamicTimePoint(id1, F(0)).absoluteTime == -1)
	assert(ld:getDynamicTimePoint(id1, F(1)).absoluteTime == 0)
	assert(ld:getDynamicTimePoint(id1, F(1.5)).absoluteTime == 0.5)
	assert(ld:getDynamicTimePoint(id1, F(5)).absoluteTime == 4)
	-- assert(ld:getDynamicTimePoint(id1, F(11)).absoluteTime == 10)
	assert(ld:getDynamicTimePoint(id2, F(0)).absoluteTime == 10)
	assert(ld:getDynamicTimePoint(id3, F(4)).absoluteTime == 28)

	assert(ld:getDynamicTimePointAbsolute(192, 0) == tp1)
	assert(ld:getDynamicTimePointAbsolute(192, -2) == tp_1)
	assert(ld:getDynamicTimePointAbsolute(192, 12) == tp11)
	assert(ld:getDynamicTimePointAbsolute(192, 20) == id3.timePoint)
	assert(ld:getDynamicTimePointAbsolute(192, 22) == tp16_)
	assert(ld:getDynamicTimePointAbsolute(192, 23))

	assert(ld:getDynamicTimePoint(id1, F(-2)).visualTime == -3)
	assert(ld:getDynamicTimePoint(id1, F(0)).visualTime == -1)
	assert(ld:getDynamicTimePoint(id1, F(1)).visualTime == 0)
	assert(ld:getDynamicTimePoint(id1, F(1.5)).visualTime == 0.5)
	assert(ld:getDynamicTimePoint(id1, F(5)).visualTime == 4)
	assert(ld:getDynamicTimePoint(id2, F(0)).visualTime == 10)
	assert(ld:getDynamicTimePoint(id3, F(4)).visualTime == 28)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local tp_6 = ld:getTimePoint(id1, F(-6))
	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp6 = ld:getTimePoint(id1, F(6))
	local tp11 = ld:getTimePoint(id2, F(1))
	local tp21 = ld:getTimePoint(id2, F(11))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 11)
	assert(tp21.absoluteTime == 21)

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 5))

	assert(id1.beats == F(5))
	assert(id3.beats == F(5))
	assert(id2.beats == F(1))

	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)

	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 15))

	assert(id1.beats == F(5))
	assert(id3.beats == F(5))
	assert(id2.beats == F(5))
	assert(id4.beats == F(1))

	assert(tp11.absoluteTime == 11)
	assert(tp21.absoluteTime == 21)

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5))

	assert(id1.beats == F(5))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp_6.intervalData == id0)
	assert(tp_1.intervalData == id0)
	assert(tp1.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local tp5 = ld:getTimePoint(id1, F(5))
	local tp6 = ld:getTimePoint(id1, F(6))

	assert(tp5.absoluteTime == 5)
	assert(tp6.absoluteTime == 6)
	assert(tp5.intervalData == id1)
	assert(tp6.intervalData == id1)

	local id3 = ld:splitInterval(tp5)

	assert(tp5.absoluteTime == 5)
	assert(tp6.absoluteTime == 6)
	assert(tp5.intervalData == id3)
	assert(tp6.intervalData == id3)
	assert(tp5.time == F(0))
	assert(tp6.time == F(1))

	local tp5_ = ld:getTimePoint(id3, F(0))
	local tp6_ = ld:getTimePoint(id3, F(1))

	assert(tp5_ == tp5)
	assert(("%p"):format(tp5_) == ("%p"):format(tp5))
	assert(tp5_.absoluteTime == 5)
	assert(tp5_.intervalData == id3)

	assert(tp6_ == tp6)
	assert(("%p"):format(tp6_) == ("%p"):format(tp6))
	assert(tp6_.absoluteTime == 6)
	assert(tp6_.intervalData == id3)

	ld:mergeInterval(tp5)

	assert(tp5.absoluteTime == 5)
	assert(tp6.absoluteTime == 6)
	assert(tp5.intervalData == id1)
	assert(tp6.intervalData == id1)
	assert(tp5.time == F(5))
	assert(tp6.time == F(6))

	local tp11 = ld:getTimePoint(id2, F(1))
	local tp15 = ld:getTimePoint(id2, F(5))
	local tp16 = ld:getTimePoint(id2, F(6))

	id3 = ld:splitInterval(tp15)

	assert(tp11.absoluteTime == 11)
	assert(tp15.absoluteTime == 15)
	assert(tp16.absoluteTime == 16)
	assert(tp11.intervalData == id2)
	assert(tp15.intervalData == id3)
	assert(tp16.intervalData == id3)
	assert(tp11.time == F(1))
	assert(tp15.time == F(0))
	assert(tp16.time == F(1))

	ld:mergeInterval(tp15)

	assert(tp11.absoluteTime == 11)
	assert(tp15.absoluteTime == 15)
	assert(tp16.absoluteTime == 16)
	assert(tp11.intervalData == id2)
	assert(tp15.intervalData == id2)
	assert(tp16.intervalData == id2)
	assert(tp11.time == F(1))
	assert(tp15.time == F(5))
	assert(tp16.time == F(6))

	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp_5 = ld:getTimePoint(id1, F(-5))
	local tp_6 = ld:getTimePoint(id1, F(-6))

	id3 = ld:splitInterval(tp_5)

	assert(tp_1.absoluteTime == -1)
	assert(tp_5.absoluteTime == -5)
	assert(tp_6.absoluteTime == -6)
	assert(tp_1.intervalData == id3)
	assert(tp_5.intervalData == id3)
	assert(tp_6.intervalData == id3)
	assert(tp_1.time == F(4))
	assert(tp_5.time == F(0))
	assert(tp_6.time == F(-1))

	ld:mergeInterval(tp_5)

	assert(tp_1.absoluteTime == -1)
	assert(tp_5.absoluteTime == -5)
	assert(tp_6.absoluteTime == -6)
	assert(tp_1.intervalData == id1)
	assert(tp_5.intervalData == id1)
	assert(tp_6.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local tp5 = ld:getTimePoint(id1, F(5))
	assert(tp5.absoluteTime == 5)

	ld:moveInterval(id2, 20)
	assert(tp5.absoluteTime == 10)

	ld:moveInterval(id2, 20)
	ld:updateInterval(id1, F(20))
	assert(tp5.absoluteTime == 5)

	local tp15 = ld:getTimePoint(id1, F(15))
	assert(tp15.prev)
	assert(tp15.next)

	ld:updateInterval(id1, F(10))
	assert(not tp15.prev)
	assert(not tp15.next)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(1, F(1))

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local dtp = ld:getDynamicTimePointAbsolute(192, 0.5)
	local id0 = ld:splitInterval(dtp)
	local tp = id0.timePoint
	assert(tp.time == F(0))
	assert(tp.next.time == F(0))
	assert(tp.prev.time == F(3))
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(1, F(1))

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local id0 = ld:getIntervalData(0.5, F(10))
	local tp = id0.timePoint
	assert(tp.time == F(0))
	assert(tp.next.time == F(0))
	assert(tp.prev.time == F(3))
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(1, F(1))

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local tp = ld:getTimePoint(0.5, Fraction:new(0))
	assert(tp.time == F(0))
	assert(tp.next.time == F(0))
	assert(tp.prev.time == F(3))
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(1, F(1))

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local dtp = ld:getDynamicTimePointAbsolute(192, 0.1)
	assert(dtp.prev == id1.timePoint)
	assert(dtp.next == tp1)
	assert(tp1:tonumber() - 0.3 < 1e-6)
	local id0 = ld:splitInterval(dtp)
	assert(tp1:tonumber() - 0.3 < 1e-6)

	ld:moveInterval(id0, 0.2)
	assert(tp1:tonumber() == 1 - 0.8 / 9 * 7)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-1, 1)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(1, F(1))

	local tp = ld:getDynamicTimePointAbsolute(192, 0.99999988697193)
	assert(tp == id2.timePoint)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 20)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local tp1 = ld:getTimePoint(id1, F(5))
	local tp2 = ld:getTimePoint(id1, F(5), 1)
	local tp3 = ld:getTimePoint(id1, F(5), 2)
	ld:getExpandData(tp2, math.huge)

	assert(tp1:getVisualTime(id1.timePoint) == 5)
	assert(tp2:getVisualTime(id1.timePoint) == math.huge)
	assert(tp3:getVisualTime(id1.timePoint) == math.huge)
	assert(tp1:getVisualTime(id2.timePoint) == -math.huge)
	assert(tp2:getVisualTime(id2.timePoint) == 5)
	assert(tp3:getVisualTime(id2.timePoint) == 5)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("interval")

	local id1 = ld:insertIntervalData(0, F(10))
	local id2 = ld:insertIntervalData(10, F(1))
	local tp1 = ld:getTimePoint(id1, F(5))

	ld:compute()
	assert(tp1.absoluteTime == 5)

	local dld = DynamicLayerData:new(ld)
	dld:setRange(-10, 20)

	local tp2 = dld:getTimePoint(id1, F(6))
	assert(tp2.absoluteTime == 6)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("measure")
	ld:setSignatureMode("short")

	ld:insertTempoData(F(0), 60)
	local tp1 = ld:getTimePoint(F(1))

	ld:compute()
	assert(tp1.absoluteTime == 4)

	local dld = DynamicLayerData:new(ld)
	dld:setRange(F(-1), F(3))

	local tp2 = dld:getTimePoint(F(2))
	assert(tp2.absoluteTime == 8)

	ld = LayerData:new()
	dld:save(ld)
	tp1 = ld:getTimePoint(F(1))

	ld:compute()
	assert(tp1.absoluteTime == 4)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, F(9.5), F(0.25))
	local id2 = ld:getIntervalData(9.75, F(1), F(0.75))

	local tp1 = ld:getTimePoint(id1, F(1))
	local tp2 = ld:getTimePoint(id2, F(2))

	assert(tp1.absoluteTime == 1)
	assert(tp2.absoluteTime == 11)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, F(9.5), F(0.25))
	local id2 = ld:getIntervalData(9.75, F(1), F(0.75))

	local tp_6 = ld:getTimePoint(id1, F(-6))
	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp6 = ld:getTimePoint(id1, F(6))
	local tp11 = ld:getTimePoint(id2, F(1))
	local tp21 = ld:getTimePoint(id2, F(11))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 5))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(id1.beats == F(4.75))
	assert(id3.beats == F(4.75))
	assert(id2.beats == F(1))

	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 15))

	assert(id1.beats == F(4.75))
	assert(id3.beats == F(4.75))
	assert(id2.beats == F(5.25))
	assert(id4.beats == F(1))

	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5))

	assert(id1.beats == F(4.75))
	assert(id0.beats == F(5.25))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp_6.intervalData == id0)
	assert(tp_1.intervalData == id0)
	assert(tp1.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, F(9.5), F(0.25))
	local id2 = ld:getIntervalData(9.75, F(1), F(0.75))

	local tp_6 = ld:getTimePoint(id1, F(-6))
	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp6 = ld:getTimePoint(id1, F(6))
	local tp11 = ld:getTimePoint(id2, F(1))
	local tp21 = ld:getTimePoint(id2, F(11))

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 5.25))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(tp6.time == F(1))

	assert(id1.beats == F(5))
	assert(id3.beats == F(4.5))
	assert(id2.beats == F(1))
	assert(id1.start == F(0.25))
	assert(id3.start == F(0.25))
	assert(id2.start == F(0.75))

	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 15.25))

	assert(id1.beats == F(5))
	assert(id3.beats == F(4.5))
	assert(id2.beats == F(5.5))
	assert(id4.beats == F(1))
	assert(id1.start == F(0.25))
	assert(id3.start == F(0.25))
	assert(id2.start == F(0.75))
	assert(id4.start == F(0.25))

	assert(tp11.time == F(1))
	assert(tp21.time == F(5))

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5.25))

	assert(id1.beats == F(5))
	assert(id0.beats == F(5.5))
	assert(id0.start == F(0.75))

	assert(tp_6.time == F(0))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp_6.intervalData == id0)
	assert(tp_1.intervalData == id0)
	assert(tp1.intervalData == id1)

	ld:mergeInterval(id3.timePoint)  -- 5.25

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(tp6.time == F(6))

	assert(id1.beats == F(9.5))
	assert(id1.start == F(0.25))

	ld:mergeInterval(id0.timePoint)  -- -5.25

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(id1.beats == F(9.5))
	assert(tp_6.time == F(-6))

	ld:mergeInterval(id4.timePoint)  -- -15.25

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 1.5))

	local dtp = ld:getDynamicTimePointAbsolute(192, 1)
	assert(dtp.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("interval")
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, F(10))
	local id2 = ld:getIntervalData(10, F(1))

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 0.5))

	local dtp = ld:getDynamicTimePointAbsolute(1, 1)
	assert(dtp.time == F(1))

	local dtp = ld:getDynamicTimePointAbsolute(1, 1.6)
	assert(dtp.time == F(2))

	local dtp = ld:getDynamicTimePointAbsolute(192, 0.49999)
	assert(dtp.intervalData == id3)
	assert(dtp.time == F(0.5))

	local dtp = ld:getDynamicTimePointAbsolute(192, 9.9999)
	assert(dtp.intervalData == id2)
	assert(dtp.time == F(0))
end
