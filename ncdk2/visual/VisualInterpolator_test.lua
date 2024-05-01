local VisualInterpolator = require("ncdk2.visual.VisualInterpolator")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local Point = require("ncdk2.tp.Point")

local test = {}

function test.absolute(t)
	local itp = VisualInterpolator()

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
	local itp = VisualInterpolator()

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

function test.sections(t)
	local itp = VisualInterpolator()

	local visualPoints = {
		VisualPoint(Point(0)),
		VisualPoint(Point(0)),
	}
	visualPoints[2].section = 1

	local vp = VisualPoint(Point(0))
	itp:interpolate(visualPoints, 1, vp, "absolute")
	t:eq(vp.visualTime, 0)
	t:eq(vp.section, 0)

	vp.section = 1
	itp:interpolate(visualPoints, 1, vp, "visual")
	t:eq(vp.visualTime, 0)
	t:eq(vp.section, 1)
end

function test.negative(t)
	--[[
---v1------------------v2----
							v3
		---------vp----------
	   v4
		---v5------------------v6---
	]]

	local itp = VisualInterpolator()

	local visualPoints = {  -- always ordered by absolute time
		VisualPoint(Point(1)),
		VisualPoint(Point(6)),
		VisualPoint(Point(7)),
		VisualPoint(Point(12)),
		VisualPoint(Point(13)),
		VisualPoint(Point(18)),
	}
	visualPoints[1].visualTime = 1
	visualPoints[2].visualTime = 6
	visualPoints[3].visualTime = 7
	visualPoints[4].visualTime = 2
	visualPoints[5].visualTime = 3
	visualPoints[6].visualTime = 8
	visualPoints[3].currentSpeed = -1

	local vp = VisualPoint(Point(9.5))
	local index = itp:interpolate(visualPoints, 1, vp, "absolute")
	t:eq(index, 3)
	t:eq(vp.visualTime, 4.5)

	index = itp:interpolate(visualPoints, 1, vp, "visual")
	t:eq(index, 1)
	t:eq(vp.point.absoluteTime, 4.5)

	index = itp:interpolate(visualPoints, 2, vp, "visual")
	t:eq(index, 1)
	t:eq(vp.point.absoluteTime, 4.5)

	index = itp:interpolate(visualPoints, 3, vp, "visual")
	t:eq(index, 1)
	t:eq(vp.point.absoluteTime, 4.5)

	index = itp:interpolate(visualPoints, 4, vp, "visual")
	t:eq(index, 5)
	t:eq(vp.point.absoluteTime, 14.5)
end

return test
