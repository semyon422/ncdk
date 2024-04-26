local Interpolator = require("ncdk2.visual.Interpolator")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local Point = require("ncdk2.tp.Point")

local test = {}

function test.absolute(t)
	local itp = Interpolator()

	local points = {
		Point(0),
		Point(1),
	}

	local visualPoints = {
		VisualPoint(points[1]),
		VisualPoint(points[2]),
	}
	visualPoints[1].visualTime = 2
	visualPoints[2].visualTime = 4
	visualPoints[1].currentSpeed = 2

	local vp = VisualPoint(Point(0.5))

	local index = itp:interpolate(visualPoints, 1, vp, "absolute")
	t:eq(index, 1)
	t:eq(vp.visualTime, 3)
end

function test.visual(t)
	local itp = Interpolator()

	local points = {
		Point(0),
		Point(1),
	}

	local visualPoints = {
		VisualPoint(points[1]),
		VisualPoint(points[2]),
	}
	visualPoints[1].visualTime = 2
	visualPoints[2].visualTime = 4
	visualPoints[1].currentSpeed = 2

	local vp = VisualPoint(Point())
	vp.visualTime = 3

	local index = itp:interpolate(visualPoints, 1, vp, "visual")
	t:eq(index, 1)
	t:eq(vp.point.absoluteTime, 0.5)
end

return test
