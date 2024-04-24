local Interpolator = require("ncdk2.visual.Interpolator")
local VisualTimePoint = require("ncdk2.visual.VisualTimePoint")
local TimePoint = require("ncdk2.tp.TimePoint")

local test = {}

function test.absolute(t)
	local itp = Interpolator()

	local timePoints = {
		TimePoint({absoluteTime = 0}),
		TimePoint({absoluteTime = 1}),
	}

	local visualTimePoints = {
		VisualTimePoint(timePoints[1]),
		VisualTimePoint(timePoints[2]),
	}
	visualTimePoints[1].visualTime = 2
	visualTimePoints[2].visualTime = 4
	visualTimePoints[1].currentSpeed = 2

	local vtp = VisualTimePoint(TimePoint({absoluteTime = 0.5}))

	local index = itp:interpolate(visualTimePoints, 1, vtp, "absolute")
	t:eq(index, 1)
	t:eq(vtp.visualTime, 3)
end

function test.visual(t)
	local itp = Interpolator()

	local timePoints = {
		TimePoint({absoluteTime = 0}),
		TimePoint({absoluteTime = 1}),
	}

	local visualTimePoints = {
		VisualTimePoint(timePoints[1]),
		VisualTimePoint(timePoints[2]),
	}
	visualTimePoints[1].visualTime = 2
	visualTimePoints[2].visualTime = 4
	visualTimePoints[1].currentSpeed = 2

	local vtp = VisualTimePoint(TimePoint())
	vtp.visualTime = 3

	local index = itp:interpolate(visualTimePoints, 1, vtp, "visual")
	t:eq(index, 1)
	t:eq(vtp.timePoint.absoluteTime, 0.5)
end

return test
