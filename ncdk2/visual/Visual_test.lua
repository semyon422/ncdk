local VisualPoint = require("ncdk2.visual.VisualPoint")
local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")
local Visual = require("ncdk2.visual.Visual")
local Point = require("ncdk2.tp.Point")
local Tempo = require("ncdk2.to.Tempo")

local test = {}

function test.basic(t)
	local vis = Visual()

	local vp0 = vis:newPoint(Point(-1))
	local vp1 = vis:newPoint(Point(1))
	local vp2 = vis:newPoint(Point(2))
	local vp3 = vis:newPoint(Point(3))

	vp1._velocity = Velocity(2)
	vp2._velocity = Velocity(3)

	vis:compute()

	t:eq(vp0.visualTime, -2)
	t:eq(vp1.visualTime, 2)
	t:eq(vp2.visualTime, 4)
	t:eq(vp3.visualTime, 7)
end

function test.no_zero_point(t)
	local vis = Visual()

	local vp1 = vis:newPoint(Point(-1))
	local vp2 = vis:newPoint(Point(1))

	vp1._velocity = Velocity()

	vis:compute()

	t:eq(vp1.visualTime, -1)
	t:eq(vp2.visualTime, 1)
end

function test.inf_expand(t)
	local vis = Visual()

	local vp0 = vis:newPoint(Point(0))

	local point = Point(5)
	local vp1 = vis:newPoint(point)
	local vp2 = vis:newPoint(point)
	local vp3 = vis:newPoint(point)

	local vp10 = vis:newPoint(Point(10))

	vp2._expand = Expand(math.huge)

	vis:compute()

	t:eq(vp1:getVisualTime(vp0), 5)
	t:eq(vp2:getVisualTime(vp0), math.huge)
	t:eq(vp3:getVisualTime(vp0), math.huge)

	t:eq(vp1:getVisualTime(vp10), -math.huge)
	t:eq(vp2:getVisualTime(vp10), 5)
	t:eq(vp3:getVisualTime(vp10), 5)
end

function test.inf_expand_back(t)
	local vis = Visual()

	local vp0 = vis:newPoint(Point(0))

	local point = Point(5)
	local vp1 = vis:newPoint(point)
	local vp2 = vis:newPoint(point)
	local vp3 = vis:newPoint(point)
	local vp4 = vis:newPoint(point)
	local vp5 = vis:newPoint(point)

	local vp10 = vis:newPoint(Point(10))

	vp2._expand = Expand(math.huge)
	vp3._expand = Expand(1)
	vp4._expand = Expand(-math.huge)

	vis:compute()

	t:eq(vp1:getVisualTime(vp0), 5)
	t:eq(vp2:getVisualTime(vp0), math.huge)
	t:eq(vp3:getVisualTime(vp0), math.huge)
	t:eq(vp4:getVisualTime(vp0), 5)
	t:eq(vp5:getVisualTime(vp0), 5)

	t:eq(vp1:getVisualTime(vp10), 5)
	t:eq(vp2:getVisualTime(vp10), math.huge)
	t:eq(vp3:getVisualTime(vp10), math.huge)
	t:eq(vp4:getVisualTime(vp10), 5)
	t:eq(vp5:getVisualTime(vp10), 5)

	t:eq(vp3:getVisualTime(vp2), 6)
end

function test.tempo(t)
	local vis = Visual()
	vis.primaryTempo = 60  -- tempo requires primaryTempo to affect visual time

	local p0 = Point(0)
	local p1 = Point(1)

	p0.tempo = Tempo(120)
	p1.tempo = Tempo(120)

	local vp0 = vis:newPoint(p0)
	local vp1 = vis:newPoint(p1)

	vis:compute()

	t:eq(vp0.visualTime, 0)
	t:eq(vp1.visualTime, 2)  -- 1 * 120 / 60
end

function test.stop(t)
	local vis = Visual()
	vis.primaryTempo = 60  -- stop requires primaryTempo to affect visual time

	local p0 = Point(0)
	local p1 = Point(1)
	p1._stop = {}

	local vp0 = vis:newPoint(p0)
	local vp1 = vis:newPoint(p1)

	vis:compute()

	t:eq(vp0.visualTime, 0)
	t:eq(vp1.visualTime, 0)  -- 0
end

function test.tempo_expand(t)
	local vis = Visual()
	vis.primaryTempo = 60

	local point = Point(0)
	point.tempo = Tempo(120)

	local vp0 = vis:newPoint(point)
	local vp1 = vis:newPoint(point)

	vp1._expand = Expand(1)  -- 1 beat

	vis:compute()

	t:eq(vp1.visualTime, 0.5)  -- 1 beat in 120 bpm is 0.5 seconds
end

function test.interval_expand(t)
	local vis = Visual()

	local point = Point(0)
	point.interval = {getBeatDuration = function() return 60 / 120 end}

	local vp0 = vis:newPoint(point)
	local vp1 = vis:newPoint(point)

	vp1._expand = Expand(1)  -- 1 beat

	vis:compute()

	t:eq(vp1.visualTime, 0.5)  -- 1 beat in 120 bpm is 0.5 seconds
end

return test
