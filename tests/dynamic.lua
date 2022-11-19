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

	ld:getVelocityData(tp1, 1)
	ld:getVelocityData(tp2, 2)

	assert(tp2.zeroClearVisualTime == tp1.absoluteTime + 4)
	assert(tp3.zeroClearVisualTime == tp2.absoluteTime + 8)
	assert(tp3.zeroClearVisualTime == tp1.absoluteTime + 12)
	assert(tp4.zeroClearVisualTime == tp1.absoluteTime - 4)

	ld:removeVelocityData(tp1)

	assert(tp2.zeroClearVisualTime == 8)
	assert(tp3.zeroClearVisualTime == 16)
	assert(tp4.zeroClearVisualTime == -8)
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
	assert(dtp.zeroClearVisualTime == 2)

	dtp = ld:getDynamicTimePoint(F(-1), -1)
	assert(dtp.absoluteTime == -4)
	assert(dtp.zeroClearVisualTime == -4)

	dtp = ld:getDynamicTimePoint(F(3.5), -1)
	assert(dtp.absoluteTime == 14)
	assert(dtp.zeroClearVisualTime == 14)

	ld:getStopData(F(1), F(4))
	dtp = ld:getDynamicTimePoint(F(1), -1)
	assert(dtp.absoluteTime == 4)
	assert(dtp.zeroClearVisualTime == 4)
	dtp = ld:getDynamicTimePoint(F(1), 1)
	assert(dtp.absoluteTime == 8)
	assert(dtp.zeroClearVisualTime == 8)
end

do
	local ld = DynamicLayerData:new()
	ld:setTimeMode("measure")
	ld:setRange(F(-10), F(10))
	ld:getTempoData(F(0), 60)

	ld:getExpandData(ld:getTimePoint(F(1)), F(1))

	assert(ld:getTimePoint(F(1), -1, -1).zeroClearVisualTime == 4)
	assert(ld:getTimePoint(F(1), -1, 1).zeroClearVisualTime == 5)

	ld:removeExpandData(ld:getTimePoint(F(1)))

	assert(ld:getTimePoint(F(1), -1, -1).zeroClearVisualTime == 4)
	assert(ld:getTimePoint(F(1), -1, 1).zeroClearVisualTime == 4)
end
