local LayerData = require("ncdk.LayerData")
local Fraction = require("ncdk.Fraction")

---@param n number
---@return ncdk.Fraction
local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = LayerData()
	ld:setTimeMode("measure")

	ld:insertTempoData(F(0), 60)

	ld:insertStopData(F(1), F(4))
	ld:insertStopData(F(2), F(4))

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
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = LayerData()
	ld:setTimeMode("measure")

	ld:insertTempoData(F(0), 60)

	ld:insertStopData(F(-1), F(4))
	ld:insertStopData(F(1), F(4))

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
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = LayerData()
	ld:setTimeMode("measure")

	ld:insertTempoData(F(0.5), 60)
	ld:insertTempoData(F(1.5), 120)
	ld:insertTempoData(F(2.5), 240)

	ld:insertStopData(F(-2.5), F(4))
	ld:insertStopData(F(-1), F(8))
	ld:insertStopData(F(1.5), F(2))

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
		ld:getTimePoint(_t[1], _t[2])
	end
	ld:computeTimePoints()
	for _, _t in ipairs(t) do
		assert(ld:getTimePoint(_t[1], _t[2]).absoluteTime == _t[3])
	end
end

do
	local ld = LayerData()
	ld:setTimeMode("measure")
	ld:insertTempoData(F(0), 60)

	local tp4 = ld:getTimePoint(Fraction:new(-1), -1)
	local tp1 = ld:getTimePoint(Fraction:new(0), -1)
	local tp2 = ld:getTimePoint(Fraction:new(1), -1)
	local tp3 = ld:getTimePoint(Fraction:new(2), -1)

	ld:insertVelocityData(ld:getTimePoint(F(0)), 1)
	ld:insertVelocityData(ld:getTimePoint(F(1)), 2)

	ld:computeTimePoints()

	assert(tp2.visualTime == tp1.absoluteTime + 4)
	assert(tp3.visualTime == tp2.absoluteTime + 8)
	assert(tp3.visualTime == tp1.absoluteTime + 12)
	assert(tp4.visualTime == tp1.absoluteTime - 4)
end
