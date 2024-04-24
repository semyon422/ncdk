local VisualTimePoint = require("ncdk2.visual.VisualTimePoint")
local VelocityData = require("ncdk2.visual.VelocityData")
local Visual = require("ncdk2.visual.Visual")
local TimePoint = require("ncdk2.tp.TimePoint")

local test = {}

function test.basic(t)
	local vis = Visual()

	local timePoints = {
		TimePoint({absoluteTime = 0}),
		TimePoint({absoluteTime = 1}),
	}

	local vtp1 = VisualTimePoint(timePoints[1])
	local vtp2 = VisualTimePoint(timePoints[2])

	vtp1._velocityData = VelocityData(vtp1)

	local visualTimePoints = {
		vtp1,
		vtp2,
	}

	vis:compute(visualTimePoints)

	t:eq(vtp1.visualTime, 0)
	t:eq(vtp2.visualTime, 1)
end

return test
