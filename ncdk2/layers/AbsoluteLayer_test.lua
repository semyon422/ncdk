local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local Velocity = require("ncdk2.visual.Velocity")

local test = {}

function test.basic(t)
	local layer = AbsoluteLayer()

	local p_0 = layer:getPoint(0)
	local vp_0 = layer.visual:newPoint(p_0)
	vp_0._velocity = Velocity(2)

	local p_1 = layer:getPoint(2)
	local vp_1 = layer.visual:newPoint(p_1)

	layer:compute()

	t:eq(vp_1.visualTime, 4)
	t:eq(vp_1.point.absoluteTime, 2)
end

return test
