local VisualPoint = require("ncdk2.visual.VisualPoint")
local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")
local Visual = require("ncdk2.visual.Visual")
local Point = require("ncdk2.tp.Point")
local Tempo = require("ncdk2.to.Tempo")
local Interval = require("ncdk2.to.Interval")

local test = {}

function test.basic(t)
	local vis = Visual()

	local vp0 = VisualPoint(Point(-1))
	local vp1 = VisualPoint(Point(1))
	local vp2 = VisualPoint(Point(2))
	local vp3 = VisualPoint(Point(3))

	vp1._velocity = Velocity(2)
	vp2._velocity = Velocity(3)

	vis:compute({vp0, vp1, vp2, vp3})

	t:eq(vp0.visualTime, -2)
	t:eq(vp1.visualTime, 2)
	t:eq(vp2.visualTime, 4)
	t:eq(vp3.visualTime, 7)
end

function test.no_zero_point(t)
	local vis = Visual()

	local points = {
		Point(-1),
		Point(1),
	}

	local vp1 = VisualPoint(points[1])
	local vp2 = VisualPoint(points[2])

	vp1._velocity = Velocity()

	vis:compute({vp1, vp2})

	t:eq(vp1.visualTime, -1)
	t:eq(vp2.visualTime, 1)
end

function test.inf_expand(t)
	local vis = Visual()

	local vp0 = VisualPoint(Point(0))
	local vp10 = VisualPoint(Point(10))

	local point = Point(5)
	local vp1 = VisualPoint(point)
	local vp2 = VisualPoint(point)
	local vp3 = VisualPoint(point)

	vp2._expand = Expand(math.huge)

	local visualPoints = {vp0, vp1, vp2, vp3, vp10}
	vis:compute(visualPoints)

	t:eq(vp1:getVisualTime(vp0), 5)
	t:eq(vp2:getVisualTime(vp0), math.huge)
	t:eq(vp3:getVisualTime(vp0), math.huge)

	t:eq(vp1:getVisualTime(vp10), -math.huge)
	t:eq(vp2:getVisualTime(vp10), 5)
	t:eq(vp3:getVisualTime(vp10), 5)
end

function test.tempo(t)
	local vis = Visual()
	vis.primaryTempo = 60  -- tempo requires primaryTempo to affect visual time

	local p0 = Point(0)
	local p1 = Point(1)

	p0.tempo = Tempo(120)
	p1.tempo = Tempo(120)

	local vp0 = VisualPoint(p0)
	local vp1 = VisualPoint(p1)

	local visualPoints = {vp0, vp1}
	vis:compute(visualPoints)

	t:eq(vp0.visualTime, 0)
	t:eq(vp1.visualTime, 2)  -- 1 * 120 / 60 
end

function test.stop(t)
	local vis = Visual()
	vis.primaryTempo = 60  -- stop requires primaryTempo to affect visual time

	local p0 = Point(0)
	local p1 = Point(1)
	p1._stop = {}

	local vp0 = VisualPoint(p0)
	local vp1 = VisualPoint(p1)

	local visualPoints = {vp0, vp1}
	vis:compute(visualPoints)

	t:eq(vp0.visualTime, 0)
	t:eq(vp1.visualTime, 0)  -- 0
end

function test.tempo_expand(t)
	local vis = Visual()
	vis.primaryTempo = 60

	local point = Point(0)
	point.tempo = Tempo(120)

	local vp0 = VisualPoint(point)
	local vp1 = VisualPoint(point)

	vp1._expand = Expand(1)  -- 1 beat

	local visualPoints = {vp0, vp1}
	vis:compute(visualPoints)

	t:eq(vp1.visualTime, 0.5)  -- 1 beat in 120 bpm is 0.5 seconds
end

function test.interval_expand(t)
	local vis = Visual()

	local point = Point(0)
	point.interval = {getBeatDuration = function() return 60 / 120 end}

	local vp0 = VisualPoint(point)
	local vp1 = VisualPoint(point)

	vp1._expand = Expand(1)  -- 1 beat

	local visualPoints = {vp0, vp1}
	vis:compute(visualPoints)

	t:eq(vp1.visualTime, 0.5)  -- 1 beat in 120 bpm is 0.5 seconds
end

return test
