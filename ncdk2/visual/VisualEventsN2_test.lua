local Velocity = require("ncdk2.visual.Velocity")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local VisualEventsN2 = require("ncdk2.visual.VisualEventsN2")

local test = {}

function test.basic(t)
	local vp = VisualPoint(Point(0))
	vp._velocity = Velocity(1)

	local ve = VisualEventsN2()

	local events = ve:generate({vp}, {-1, 1})
	t:eq(#events, 2)
	t:eq(events[1].time, -1)
	t:eq(events[1].action, 1)
	t:eq(events[2].time, 1)
	t:eq(events[2].action, -1)
end

function test.local_1(t)
	local vp_1 = VisualPoint(Point(0))
	vp_1._velocity = Velocity(1)

	local vp_2 = VisualPoint(Point(1))
	vp_2._velocity = Velocity(1, 0.5)

	local ve = VisualEventsN2()

	local events = ve:generate({vp_1, vp_2}, {-1, 1})
	t:eq(#events, 4)
end

return test
