local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local VisualEventsN2 = require("ncdk2.visual.VisualEventsN2")
local Visual = require("ncdk2.visual.Visual")

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

function test.expand(t)
	local vis = Visual()
	local vps = {
		vis:newPoint(Point(-100)),
		vis:newPoint(Point(0)),
		vis:newPoint(Point(0)),
		vis:newPoint(Point(100)),
	}
	vps[3]._expand = Expand(50)

	vis:compute()

	local ve = VisualEventsN2()
	local events = ve:generate(vps, {-1, 1})

	for _, e in ipairs(events) do
		e.point_vt = e.point.visualTime
		e.point_at = e.point.point.absoluteTime
		e.point = nil
	end

	t:eq(#events, 8)

	local zero_vp = VisualPoint(Point(0))
	local base_index = vis.interpolator:getBaseIndex(vps, 1, zero_vp, function(p)
		return p.point
	end)
	t:eq(base_index, 2)

	-- t:tdeq(events, {
	-- 	{action=1,point_at=-100,point_vt=-150,time=-101},
	-- 	{action=-1,point_at=-100,point_vt=-150,time=-99},
	-- 	{action=1,point_at=0,point_vt=-50,time=-1},
	-- 	{action=-1,point_at=0,point_vt=0,time=1},
	-- 	{action=1,point_at=100,point_vt=100,time=99},
	-- 	{action=-1,point_at=100,point_vt=100,time=101}
	-- })

	-- events = ve:generate(vps, {-1000, 1000})
	-- t:eq(#events, #vps * 2)
end

function test.zero(t)
	local vis = Visual()
	local vps = {
		vis:newPoint(Point(-100)),
		vis:newPoint(Point(0)),
		vis:newPoint(Point(100)),
		vis:newPoint(Point(200)),
	}
	vps[1]._velocity = Velocity(1)
	vps[2]._velocity = Velocity(0)
	vps[3]._velocity = Velocity(1)

	vis:compute()

	local ve = VisualEventsN2()
	local events = ve:generate(vps, {-1, 1})

	for _, e in ipairs(events) do
		e.point_vt = e.point.visualTime
		e.point_at = e.point.point.absoluteTime
		e.point = nil
	end

	t:eq(#events, 8)

	t:tdeq(events, {
		{action=1,point_at=-100,point_vt=-100,time=-101},
		{action=-1,point_at=-100,point_vt=-100,time=-99},
		{action=1,point_at=0,point_vt=0,time=-1},
		{action=1,point_at=100,point_vt=0,time=-1},
		{action=-1,point_at=0,point_vt=0,time=101},
		{action=-1,point_at=100,point_vt=0,time=101},
		{action=1,point_at=200,point_vt=100,time=199},
		{action=-1,point_at=200,point_vt=100,time=201}
	})

	events = ve:generate(vps, {-1000, 1000})
	t:eq(#events, #vps * 2)
end

function test.negative(t)
	local vis = Visual()
	local vps = {
		vis:newPoint(Point(-100)),
		vis:newPoint(Point(0)),
		vis:newPoint(Point(100)),
		vis:newPoint(Point(200)),
		vis:newPoint(Point(300)),
		vis:newPoint(Point(400)),
	}
	vps[2]._velocity = Velocity(1)
	vps[3]._velocity = Velocity(-1)
	vps[4]._velocity = Velocity(1)

	vis:compute()

	local ve = VisualEventsN2()
	local events = ve:generate(vps, {-1, 1})

	for _, e in ipairs(events) do
		e.point_vt = e.point.visualTime
		e.point_at = e.point.point.absoluteTime
		e.point = nil
	end

	t:eq(#events, 20)

	t:tdeq(events, {
		{action=1,point_at=-100,point_vt=-100,time=-101},
		{action=-1,point_at=-100,point_vt=-100,time=-99},
		{action=1,point_at=0,point_vt=0,time=-1},
		{action=1,point_at=200,point_vt=0,time=-1},
		{action=-1,point_at=0,point_vt=0,time=1},
		{action=-1,point_at=200,point_vt=0,time=1},
		{action=1,point_at=100,point_vt=100,time=99},
		{action=1,point_at=300,point_vt=100,time=99},
		{action=-1,point_at=100,point_vt=100,time=101},
		{action=-1,point_at=300,point_vt=100,time=101},
		{action=1,point_at=0,point_vt=0,time=199},
		{action=1,point_at=200,point_vt=0,time=199},
		{action=-1,point_at=0,point_vt=0,time=201},
		{action=-1,point_at=200,point_vt=0,time=201},
		{action=1,point_at=100,point_vt=100,time=299},
		{action=1,point_at=300,point_vt=100,time=299},
		{action=-1,point_at=100,point_vt=100,time=301},
		{action=-1,point_at=300,point_vt=100,time=301},
		{action=1,point_at=400,point_vt=200,time=399},
		{action=-1,point_at=400,point_vt=200,time=401}
	})

	events = ve:generate(vps, {-1000, 1000})
	t:eq(#events, #vps * 2)
end

return test
