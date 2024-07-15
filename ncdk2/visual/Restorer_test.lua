local Visual = require("ncdk2.visual.Visual")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local Point = require("ncdk2.tp.Point")
local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")
local Restorer = require("ncdk2.visual.Restorer")

local test = {}

function test.basic_velocity(t)
	local vp0 = VisualPoint(Point(0))
	vp0.visualTime = 0

	local vp1 = VisualPoint(Point(1))
	vp1.visualTime = 2

	Restorer:restore({vp0, vp1})

	t:eq(vp0._velocity.currentSpeed, 2)
end

function test.basic_expand(t)
	local vp0 = VisualPoint(Point(0))
	vp0.visualTime = 0

	local vp1 = VisualPoint(Point(0))
	vp1.visualTime = 2

	Restorer:restore({vp0, vp1})

	t:eq(vp0._expand.duration, 2)
end

return test
