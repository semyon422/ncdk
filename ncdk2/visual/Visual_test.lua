local VisualPoint = require("ncdk2.visual.VisualPoint")
local Velocity = require("ncdk2.visual.Velocity")
local Visual = require("ncdk2.visual.Visual")
local Point = require("ncdk2.tp.Point")

local test = {}

function test.basic(t)
	local vis = Visual()

	local points = {
		Point(0),
		Point(1),
	}

	local vp1 = VisualPoint(points[1])
	local vp2 = VisualPoint(points[2])

	vp1._velocity = Velocity()

	local visualPoints = {
		vp1,
		vp2,
	}

	vis:compute(visualPoints)

	t:eq(vp1.visualTime, 0)
	t:eq(vp2.visualTime, 1)
end

return test
