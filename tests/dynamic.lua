local DynamicLayerData = require("ncdk.DynamicLayerData")
local LayerData = require("ncdk.LayerData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 20)

	local id = ld:getIntervalData(0, 10)
	ld:getIntervalData(10, 1)
	ld:getTimePoint(id, F(5), 1)

	ld:getExpandData(ld:getTimePoint(id, F(5), 1), F(1))

	assert(tostring(ld:getDynamicTimePoint(id, F(5))) == "(0000000000000000[0],0.0/1+10,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePoint(id, F(5), 0)) == "(0000000000000000[0],0.0/1+10,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePoint(id, F(5), 1)) == "(0000000000000000[0],0.0/1+10,5.0/1,1)")

	assert(tostring(ld:getDynamicTimePointAbsolute(192, 5, 0)) == "(0000000000000000[0],0.0/1+10,5.0/1,0)")
	assert(tostring(ld:getDynamicTimePointAbsolute(192, 5, 1)) == "(0000000000000000[0],0.0/1+10,5.0/1,1)")
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(-1, 11)
	local id2 = ld:getIntervalData(10, 5)
	local id3 = ld:getIntervalData(20, 1)

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

	-- in interval time mode it is not guaranteed that absoluteTime = visualTime = 0
	local dvt = ld:getDynamicTimePoint(id1, F(-2)).visualTime + 3
	assert(ld:getDynamicTimePoint(id1, F(-2)).visualTime == -3 + dvt)
	assert(ld:getDynamicTimePoint(id1, F(0)).visualTime == -1 + dvt)
	assert(ld:getDynamicTimePoint(id1, F(1)).visualTime == 0 + dvt)
	assert(ld:getDynamicTimePoint(id1, F(1.5)).visualTime == 0.5 + dvt)
	assert(ld:getDynamicTimePoint(id1, F(5)).visualTime == 4 + dvt)
	assert(ld:getDynamicTimePoint(id2, F(0)).visualTime == 10 + dvt)
	assert(ld:getDynamicTimePoint(id3, F(4)).visualTime == 28 + dvt)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

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

	assert(id1.beats == 5)
	assert(id3.beats == 5)
	assert(id2.beats == 1)

	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)

	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 15))

	assert(id1.beats == 5)
	assert(id3.beats == 5)
	assert(id2.beats == 5)
	assert(id4.beats == 1)

	assert(tp11.absoluteTime == 11)
	assert(tp21.absoluteTime == 21)

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5))

	assert(id1.beats == 5)

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp_6.intervalData == id0)
	assert(tp_1.intervalData == id0)
	assert(tp1.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

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
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

	local tp5 = ld:getTimePoint(id1, F(5))
	assert(tp5.absoluteTime == 5)

	ld:moveInterval(id2, 20)
	assert(tp5.absoluteTime == 10)

	ld:moveInterval(id2, 20)
	ld:updateInterval(id1, 20)
	assert(tp5.absoluteTime == 5)

	local tp15 = ld:getTimePoint(id1, F(15))
	assert(tp15.prev)
	assert(tp15.next)

	ld:updateInterval(id1, 10)
	assert(not tp15.prev)
	assert(not tp15.next)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

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
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local id0 = ld:getIntervalData(0.5, 10)
	local tp = id0.timePoint
	assert(tp.time == F(0))
	assert(tp.next.time == F(0))
	assert(tp.prev.time == F(3))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

	local tp1 = ld:getTimePoint(id1, Fraction(3))

	local tp = ld:getTimePoint(0.5, Fraction:new(0))
	assert(tp.time == F(0))
	assert(tp.next.time == F(0))
	assert(tp.prev.time == F(3))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-1, 2)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

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
	ld:setRange(-1, 1)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

	local tp = ld:getDynamicTimePointAbsolute(192, 0.99999988697193)
	assert(tp == id2.timePoint)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 20)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

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

	local id1 = ld:insertIntervalData(0, 10)
	local id2 = ld:insertIntervalData(10, 1)
	local tp1 = ld:getTimePoint(id1, F(5))

	ld:compute()
	assert(tp1.absoluteTime == 5)

	local dld = DynamicLayerData:new(ld)
	dld:setRange(-10, 20)

	local tp2 = dld:getTimePoint(id1, F(6))
	assert(tp2.absoluteTime == 6)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, 9, F(0.25))
	local id2 = ld:getIntervalData(9.75, 1, F(0.75))

	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp2 = ld:getTimePoint(id2, F(2))

	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp2.absoluteTime == 11)

	local tp = ld:getDynamicTimePointAbsolute(192, 5)
	assert(tp.time == F(5))

	local tp = ld:getDynamicTimePointAbsolute(192, 11)
	assert(tp.time == F(2))

	local tp = ld:getDynamicTimePointAbsolute(192, -1)
	assert(tp.time == F(-1))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, 9, F(0.25))
	local id2 = ld:getIntervalData(9.75, 1, F(0.75))

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
	assert(id3.timePoint.time == F(0))

	assert(id1.beats == 5)
	assert(id3.beats == 4)
	assert(id2.beats == 1)

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	local dtp = ld:getDynamicTimePointAbsolute(192, 15)
	assert(dtp.time == F(6))
	local id4 = ld:splitInterval(dtp)
	assert(id4.timePoint.time == F(0))

	assert(id1.beats == 5)
	assert(id3.beats == 4)
	assert(id2.beats == 6)
	assert(id4.beats == 1)

	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5))
	assert(id0.timePoint.time == F(0))

	assert(id1.beats == 5)
	assert(id0.beats == 5)

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp_6.intervalData == id0)
	assert(tp_1.intervalData == id0)
	assert(tp1.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.25, 9, F(0.25))
	local id2 = ld:getIntervalData(9.75, 1, F(0.75))

	local tp_6 = ld:getTimePoint(id1, F(-6))
	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp6 = ld:getTimePoint(id1, F(6))
	local tp11 = ld:getTimePoint(id2, F(1))
	local tp21 = ld:getTimePoint(id2, F(11))

	local dtp = ld:getDynamicTimePointAbsolute(192, 5.25)
	assert(dtp.time == F(5.25))
	local id3 = ld:splitInterval(dtp)

	assert(tp6.time == F(1))

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(id1.beats == 5)
	assert(id3.beats == 4)
	assert(id2.beats == 1)
	assert(id1:start() == F(0.25))
	assert(id3:start() == F(0.25))
	assert(id2:start() == F(0.75))

	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 15.25))

	assert(id1.beats == 5)
	assert(id3.beats == 4)
	assert(id2.beats == 6)
	assert(id4.beats == 1)
	assert(id1:start() == F(0.25))
	assert(id3:start() == F(0.25))
	assert(id2:start() == F(0.75))
	assert(id4:start() == F(0.25))

	assert(tp11.time == F(1))
	assert(tp21.time == F(5))

	local id0 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, -5.25))

	assert(id1.beats == 5)
	assert(id0.beats == 6)
	assert(id0:start() == F(0.75))

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

	assert(id1.beats == 9)
	assert(id1:start() == F(0.25))

	ld:mergeInterval(id0.timePoint)  -- -5.25

	assert(tp_6.absoluteTime == -6)
	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)
	assert(tp6.absoluteTime == 6)
	assert(tp11.absoluteTime == 10)
	assert(tp21.absoluteTime == 20)

	assert(id1.beats == 9)
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
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 1.5))

	local dtp = ld:getDynamicTimePointAbsolute(192, 1)
	assert(dtp.intervalData == id1)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

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

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

	local tp1 = ld:getTimePoint(id1, F(2))

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 0.5))
	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 1.25))

	ld:mergeInterval(id4.timePoint)

	assert(id3.beats == 10)
	assert(tp1.time == F(2))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

	local tp1 = ld:getTimePoint(id1, F(2))
	local tp2 = ld:getTimePoint(id1, F(3.25))

	local id3 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 0.5))
	local id4 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 1.25))

	assert(tp2.time == F(2.25))

	local id5 = ld:splitInterval(ld:getDynamicTimePointAbsolute(192, 2.75))

	ld:mergeInterval(id4.timePoint)

	assert(tp1.time == F(2))
	assert(tp2.time == F(1.25))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.5, 1, F(0.5))
	local id2 = ld:getIntervalData(1.25, 1, F(0.25))

	ld:updateInterval(id1, 0)
	assert(id1.beats == 1)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.5, 1, F(0.5))
	local id2 = ld:getIntervalData(1.5, 1, F(0.5))

	ld:updateInterval(id1, 0)
	assert(id1.beats == 1)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.5, 1, F(0.5))
	local id2 = ld:getIntervalData(1.75, 1, F(0.75))

	ld:updateInterval(id1, 0)
	assert(id1.beats == 0)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0.5, 1, F(0.5))
	local id2 = ld:getIntervalData(1.75, 1, F(0.75))

	ld:moveInterval(id2, 0)
	assert(math.abs(id1:getBeatDuration() - ld.minBeatDuration) < 1e-6)
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 1)

	local tp_1 = ld:getTimePoint(id1, F(-1))
	local tp1 = ld:getTimePoint(id1, F(1))
	local tp2 = ld:getTimePoint(id1, F(2))
	local tp3 = ld:getTimePoint(id1, F(3))
	local tp4 = ld:getTimePoint(id1, F(4))
	local tp5 = ld:getTimePoint(id1, F(5))
	local tp6 = ld:getTimePoint(id1, F(6))
	local tp7 = ld:getTimePoint(id1, F(7))

	local md_1 = ld:getMeasureData(ld:getTimePoint(id1, F(-0.5)))
	local md0 = ld:getMeasureData(ld:getTimePoint(id1, F(0)))
	local md1 = ld:getMeasureData(ld:getTimePoint(id1, F(2.5)))
	local md2 = ld:getMeasureData(ld:getTimePoint(id1, F(4)), F(0.75))
	local md3 = ld:getMeasureData(ld:getTimePoint(id1, F(6)))
	local md4 = ld:getMeasureData(ld:getTimePoint(id1, F(6.5)))

	assert(tp_1.absoluteTime == -1)
	assert(tp1.absoluteTime == 1)

	assert(tp_1:getBeatModulo() == F(0.5))
	assert(tp1:getBeatModulo() == F(0))
	assert(tp2:getBeatModulo() == F(0))
	assert(tp3:getBeatModulo() == F(0.5))
	assert(tp4:getBeatModulo() == F(0.75))
	assert(tp5:getBeatModulo() == F(0.75))
	assert(tp6:getBeatModulo() == F(0))
	assert(tp7:getBeatModulo() == F(0.5))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 10)
	local id3 = ld:getIntervalData(20, 1)

	local id, t = ld:getTimePoint(id1, F(-1)):add(F(12))
	assert(id == id2)
	assert(t == F(1))

	id, t = ld:getTimePoint(id1, F(-1)):add(F(23))
	assert(id == id3)
	assert(t == F(2))

	id, t = ld:getTimePoint(id3, F(2)):add(-F(23))
	assert(id == id1)
	assert(t == -F(1))

	t = ld:getTimePoint(id3, F(2)):sub(ld:getTimePoint(id1, F(-1)))
	assert(t == F(23))
end

do
	local ld = DynamicLayerData:new()
	ld:setRange(-10, 20)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(10, 10)

	local tps = {}
	for t = -5, 15 do
		tps[t] = ld:checkTimePoint(ld:getDynamicTimePointAbsolute(1, t))
	end

	ld:setRange(2, 8)

	ld:uncompute()
	ld:compute()

	assert(ld.ranges.timePoint.head == tps[1])
	assert(ld.ranges.timePoint.tail == tps[9])

	assert(table.concat(ld.uncomputedSection, ", ") == "-5, 1, 9, 15")
end
