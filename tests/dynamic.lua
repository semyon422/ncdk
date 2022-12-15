local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)

	local tp = ld:getTimePoint(F(0), -1)
	assert(tp.absoluteTime == 0)

	tp = ld:getTimePoint(F(1), -1)
	assert(tp.absoluteTime == 4)

	tp = ld:getTimePoint(F(-1), -1)
	assert(tp.absoluteTime == -4)

	ld:getTimePoint(F(-10), -1)
	ld:getTimePoint(F(-9), -1)
	ld:getTimePoint(F(-8), -1)
	ld:getTimePoint(F(-7), -1)
	ld:getTimePoint(F(10), -1)
	ld:getTimePoint(F(9), -1)
	ld:getTimePoint(F(8), -1)
	ld:getTimePoint(F(7), -1)

	ld:setRange(F(-8), F(-5))

	tp = ld:getTimePoint(F(-7), -1)
	assert(tp.absoluteTime == -28)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 4)

	ld:getTempoData(F(1), 120)
	assert(ld:getTimePoint(F(2), -1).absoluteTime == 6)

	ld:getTempoData(F(2), 240)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 7)

	ld:getTempoData(F(-1), 30)
	assert(ld:getTimePoint(F(-1), -1).absoluteTime == -8)

	ld:getTempoData(F(-2), 15)
	assert(ld:getTimePoint(F(-2), -1).absoluteTime == -24)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(2))

	ld:getTempoData(F(0), 60)

	assert(ld:getTimePoint(F(1), -1).absoluteTime == 4)

	ld:setRange(F(4), F(8))
	assert(ld:getTimePoint(F(4), -1).absoluteTime == 16)
	assert(ld:getTimePoint(F(5), -1).absoluteTime == 20)
	assert(ld:getTimePoint(F(6), -1).absoluteTime == 24)
	assert(ld:getTimePoint(F(7), -1).absoluteTime == 28)
	assert(ld:getTimePoint(F(8), -1).absoluteTime == 32)
	ld:setRange(F(4), F(6))

	assert(ld.timePointsRange.startObject == ld:getTimePoint(F(1), -1))
	assert(ld.timePointsRange.endObject == ld:getTimePoint(F(7), -1))
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	for i = 0, 10 do
		ld:getTimePoint(F(i), -1)
	end

	ld:setRange(F(0), F(2))

	assert(ld:getTimePoint(F(2), -1).absoluteTime == 8)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 12)
	assert(ld:getTimePoint(F(4), -1).absoluteTime == 16)
	assert(ld:getTimePoint(F(5), -1).absoluteTime == 20)

	ld:getTempoData(F(0), 120)

	assert(ld:getTimePoint(F(2), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 6)
	assert(ld:getTimePoint(F(4), -1).absoluteTime == 16)
	assert(ld:getTimePoint(F(5), -1).absoluteTime == 20)

	ld:setRange(F(5), F(7))

	assert(ld:getTimePoint(F(2), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 6)
	assert(ld:getTimePoint(F(4), -1).absoluteTime == 8)
	assert(ld:getTimePoint(F(5), -1).absoluteTime == 10)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	for i = 0, 10 do
		ld:getTimePoint(F(i), -1)
	end

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(2), -1).absoluteTime == 8)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 12)

	ld:getTempoData(F(1), 120)

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(2), -1).absoluteTime == 6)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 8)

	ld:removeTempoData(F(0))

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 2)
	assert(ld:getTimePoint(F(2), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(3), -1).absoluteTime == 6)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(0), 60)

	for i = 0, 10 do
		ld:getTimePoint(F(i), -1)
	end

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 4)
	assert(ld:getTimePoint(F(9), -1).absoluteTime == 36)
	assert(ld:getTimePoint(F(10), -1).absoluteTime == 40)

	ld:setRange(F(0), F(0))

	ld:getTempoData(F(0), 120)

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 2)
	assert(ld:getTimePoint(F(9), -1).absoluteTime == 36)
	assert(ld:getTimePoint(F(10), -1).absoluteTime == 40)

	ld:setRange(F(10), F(10))

	assert(ld:getTimePoint(F(0), -1).absoluteTime == 0)
	assert(ld:getTimePoint(F(1), -1).absoluteTime == 2)
	assert(ld:getTimePoint(F(9), -1).absoluteTime == 18)
	assert(ld:getTimePoint(F(10), -1).absoluteTime == 20)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))

	ld:getTempoData(F(0), 60)
	ld:getStopData(F(1), F(4))
	ld:getStopData(F(2), F(4))

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
		{F(-3), -1, -24},
		{F(-2.5), -1, -22},
		{F(-2.5), 1, -18},
		{F(-2), -1, -16},
		{F(-1), -1, -12},
		{F(-1), 1, -4},
		{F(0), -1, 0},
		{F(0.5), 1, 2},  -- right time point only
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
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end

	ld:removeStopData(F(-1))

	local t = {
		{F(-3), -1, -16},
		{F(-2.5), -1, -14},
		{F(-2.5), 1, -10},
		{F(-2), -1, -8},
		{F(-1), -1, -4},
		{F(-1), 1, -4},
		{F(0), -1, 0},
		{F(0.5), -1, 2},
		{F(1), -1, 4},
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

	local tp4 = ld:getTimePoint(F(-1), -1)
	local tp1 = ld:getTimePoint(F(0), -1)
	local tp2 = ld:getTimePoint(F(1), -1)
	local tp3 = ld:getTimePoint(F(2), -1)

	ld:getVelocityData(F(0), -1, 1)
	ld:getVelocityData(F(1), -1, 2)

	assert(tp2.visualTime == tp1.absoluteTime + 4)
	assert(tp3.visualTime == tp2.absoluteTime + 8)
	assert(tp3.visualTime == tp1.absoluteTime + 12)
	assert(tp4.visualTime == tp1.absoluteTime - 4)

	ld:removeVelocityData(F(0), -1)

	assert(tp2.visualTime == 8)
	assert(tp3.visualTime == 16)
	assert(tp4.visualTime == -8)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	local tp1 = ld:getTimePoint(F(0), -1)
	local tp2 = ld:getTimePoint(F(1), -1)
	local tp3 = ld:getTimePoint(F(2), -1)

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

	local tp1 = ld:getTimePoint(F(0), -1)
	local tp2 = ld:getTimePoint(F(1), -1)
	local tp3 = ld:getTimePoint(F(2), -1)

	local dtp = ld:getDynamicTimePoint(F(0.5), -1)
	assert(dtp.absoluteTime == 2)
	assert(dtp.visualTime == 2)

	dtp = ld:getDynamicTimePoint(F(-1), -1)
	assert(dtp.absoluteTime == -4)
	assert(dtp.visualTime == -4)

	dtp = ld:getDynamicTimePoint(F(3.5), -1)
	assert(dtp.absoluteTime == 14)
	assert(dtp.visualTime == 14)

	ld:getStopData(F(1), F(4))
	dtp = ld:getDynamicTimePoint(F(1), -1)
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

	ld:getExpandData(F(1), -1, F(1))

	assert(ld:getTimePoint(F(1), -1, -1).visualTime == 4)
	assert(ld:getTimePoint(F(1), -1, 1).visualTime == 5)

	ld:removeExpandData(F(1), -1)

	assert(ld:getTimePoint(F(1), -1, -1).visualTime == 4)
	assert(ld:getTimePoint(F(1), -1, 1).visualTime == 4)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(Fraction(0), Fraction(10))

	ld:getTempoData(Fraction(1), 60)
	ld:getTempoData(Fraction(3, 10, true), 120)

	local function dat(t)
		return ld:getDynamicTimePoint(Fraction(t), -1).absoluteTime
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
		return ld:getDynamicTimePointAbsolute(t, 192, -1)
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
		return ld:getDynamicTimePoint(F(t), -1)
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

	ld:getVelocityData(F(0.5), -1, 1)
	ld:getVelocityData(F(4.5), -1, 2)
	ld:getVelocityData(F(5 / 4), -1, 0)
	ld:getVelocityData(F(6 / 4), -1, 1)

	ld:getExpandData(F(2), -1, F(1))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(32, 192, -1)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(32, 192, -1)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(6), F(16))
	local dtp = ld:getDynamicTimePointAbsolute(32, 192, -1)
	assert(dtp.measureTime == F(12))

	ld:setRange(F(3), F(13))
	local dtp = ld:getDynamicTimePointAbsolute(24, 192, -1)
	assert(dtp.measureTime == F(8))

	ld:setRange(F(2), F(12))
	assert(ld:getDynamicTimePointAbsolute(22, 192, -1))
	assert(ld:getDynamicTimePoint(Fraction(2), -1))
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(0), F(10))

	ld:getTempoData(F(1), 60)

	ld:getStopData(F(5), F(1))
	ld:getExpandData(F(5), -1, F(1))
	ld:getExpandData(F(5), 1, F(1))

	assert(tostring(ld:getDynamicTimePoint(F(5))) == "5.0/1<-<-")  -- 20, 20
	assert(tostring(ld:getDynamicTimePoint(F(5), -1, -1)) == "5.0/1<-<-")  -- 20, 20
	assert(tostring(ld:getDynamicTimePoint(F(5), -1, 1)) == "5.0/1<-->")  -- 20, 21
	assert(tostring(ld:getDynamicTimePoint(F(5), 1, -1)) == "5.0/1-><-")  -- 21, 22
	assert(tostring(ld:getDynamicTimePoint(F(5), 1, 1)) == "5.0/1->->")  -- 21, 23

	assert(tostring(ld:getDynamicTimePointAbsolute(20, 192, -1, -1)) == "5.0/1<-<-")
	assert(tostring(ld:getDynamicTimePointAbsolute(20, 192, 1, -1)) == "5.0/1<-<-")
	assert(tostring(ld:getDynamicTimePointAbsolute(21, 192, -1, -1)) == "5.0/1-><-")
	assert(tostring(ld:getDynamicTimePointAbsolute(21, 192, 1, -1)) == "5.0/1-><-")
end

do
	local ld = DynamicLayerData:new()

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(F(-10), F(10))

	ld:getSignatureData(2, F(3))

	ld:getTempoData(F(1), 60)

	ld:getTimePoint(F(0))

	ld:getTimePoint(F(-5), -1, -1)
	ld:getTimePoint(F(-5), -1, 1)
	ld:getTimePoint(F(-5), 1, -1)
	ld:getTimePoint(F(-5), 1, 1)
	ld:getTimePoint(F(5), -1, -1)
	ld:getTimePoint(F(5), -1, 1)
	ld:getTimePoint(F(5), 1, -1)
	ld:getTimePoint(F(5), 1, 1)

	local range = ld.timePointsRange

	assert(tostring(range.startObject) == "-5.0/1<-<-")
	assert(tostring(range.endObject) == "5.0/1->->")

	ld:getTimePoint(F(-10))
	ld:getTimePoint(F(10))

	ld:setRange(F(-3), F(3))
	assert(tostring(range.startObject) == "-5.0/1->->")
	assert(tostring(range.endObject) == "5.0/1<-<-")

	ld:setRange(F(-5), F(5))
	assert(tostring(range.startObject) == "-10.0/1<-<-")
	assert(tostring(range.endObject) == "10.0/1<-<-")
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
	ld:setRange(F(-10), F(20))

	ld:getIntervalData(0, 10)
	ld:getIntervalData(10, 5)
	ld:getIntervalData(20, 1)

	local tp0 = ld:getTimePoint(F(0))
	local tp1 = ld:getTimePoint(F(1))
	local tp_1 = ld:getTimePoint(F(-1))
	local tp11 = ld:getTimePoint(F(11))
	local tp15 = ld:getTimePoint(F(15))
	local tp16 = ld:getTimePoint(F(16))

	assert(tp0.absoluteTime == 0)
	assert(tp1.absoluteTime == 1)
	assert(tp_1.absoluteTime == -1)
	assert(tp11.absoluteTime == 12)
	assert(tp15.absoluteTime == 20)
	assert(tp16.absoluteTime == 22)

	assert(ld:getDynamicTimePoint(F(0.5)).absoluteTime == 0.5)
	assert(ld:getDynamicTimePoint(F(13)).absoluteTime == 16)
	assert(ld:getDynamicTimePoint(F(17)).absoluteTime == 24)
	assert(ld:getDynamicTimePoint(F(-2)).absoluteTime == -2)

	assert(ld:getDynamicTimePointAbsolute(0.5, 192).measureTime == F(0.5))
	assert(ld:getDynamicTimePointAbsolute(16, 192).measureTime == F(13))
	assert(ld:getDynamicTimePointAbsolute(24, 192).measureTime == F(17))
	assert(ld:getDynamicTimePointAbsolute(-2, 192).measureTime == F(-2))
end
