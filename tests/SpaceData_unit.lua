local LayerData = require("ncdk.LayerData")
local TempoData = require("ncdk.TempoData")
local VelocityData = require("ncdk.VelocityData")
local Fraction = require("ncdk.Fraction")

local function F(n)
	return Fraction:new(n, 1000, true)
end

do
	local ld = LayerData:new()
	ld:setTimeMode("measure")
	ld:addTempoData(TempoData:new(F(0), 60))

	local tp4 = ld:getTimePoint(Fraction:new(-1), -1)
	local tp1 = ld:getTimePoint(Fraction:new(0), -1)
	local tp2 = ld:getTimePoint(Fraction:new(1), -1)
	local tp3 = ld:getTimePoint(Fraction:new(2), -1)

	ld:computeTimePoints()

	local vd = VelocityData:new(tp1)
	vd.currentSpeed = 1
	ld:addVelocityData(vd)

	vd = VelocityData:new(tp2)
	vd.currentSpeed = 2
	ld:addVelocityData(vd)

	assert(ld:getVisualTime(tp2, tp1, true) == tp1.absoluteTime + 4)
	assert(ld:getVisualTime(tp3, tp2, true) == tp2.absoluteTime + 8)
	assert(ld:getVisualTime(tp3, tp1, true) == tp1.absoluteTime + 12)
	assert(ld:getVisualTime(tp4, tp1, true) == tp1.absoluteTime - 4)

	ld:computeTimePoints()

	assert(tp2.zeroClearVisualTime == tp1.absoluteTime + 4)
	assert(tp3.zeroClearVisualTime == tp2.absoluteTime + 8)
	assert(tp3.zeroClearVisualTime == tp1.absoluteTime + 12)
	assert(tp4.zeroClearVisualTime == tp1.absoluteTime - 4)
end
