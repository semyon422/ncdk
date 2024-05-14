local Velocity = require("ncdk2.visual.Velocity")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local VisualEvents = require("ncdk2.visual.VisualEvents")
local VisualEventsN2 = require("ncdk2.visual.VisualEventsN2")
local Visual = require("ncdk2.visual.Visual")

local test = {}

---@param t any
---@param es1 ncdk2.VisualEvent[]
---@param es2 ncdk2.VisualEvent[]
local function eq_events(t, es1, es2)
	if not t:eq(#es1, #es2) then
		return
	end
	local err = 0
	for i = 1, #es1 do
		if math.abs(es1[i].time) == math.huge then
			t:eq(es1[i].time, es2[i].time)
		else
			err = err + math.abs(es1[i].time - es2[i].time)
		end
		t:eq(es1[i].action, es2[i].action)
	end
	t:lt(err / #es1, 1e-6)
end

local function new_vp(time)
	local vp = VisualPoint(Point(time))
	vp.visualTime = time
	return vp
end

function test.basic(t)
	local vp = VisualPoint(Point(0))
	vp._velocity = Velocity(1)

	local ve = VisualEvents()

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

	local ve = VisualEvents()

	local events = ve:generate({vp_1, vp_2}, {-1, 1})
	t:eq(#events, 4)
end


function test.next(t)
	local vp_1 = new_vp(0)
	local vp_2 = new_vp(1)
	local vp_3 = new_vp(2)
	local vp_4 = new_vp(3)

	local ve = VisualEvents()

	ve:generate({vp_1, vp_2, vp_3, vp_4}, {-1, 1})

	t:eq(#ve.events, 8)
	t:tdeq(ve.events, {
		{action=1,point={point={absoluteTime=0},visualTime=0},time=-1},
		{action=1,point={point={absoluteTime=1},visualTime=1},time=0},
		{action=-1,point={point={absoluteTime=0},visualTime=0},time=1},
		{action=1,point={point={absoluteTime=2},visualTime=2},time=1},
		{action=-1,point={point={absoluteTime=1},visualTime=1},time=2},
		{action=1,point={point={absoluteTime=3},visualTime=3},time=2},
		{action=-1,point={point={absoluteTime=2},visualTime=2},time=3},
		{action=-1,point={point={absoluteTime=3},visualTime=3},time=4}
	})

	local ctime = 2.5
	---@type {[ncdk2.VisualPoint]: true}
	local visiblePoints = {}
	local offset, vp, show = ve:next(0, ctime)
	while offset do
		visiblePoints[vp] = show
		offset, vp, show = ve:next(offset, ctime)
	end

	t:assert(not visiblePoints[vp_1])
	t:assert(not visiblePoints[vp_2])
	t:assert(visiblePoints[vp_3])
	t:assert(visiblePoints[vp_4])
end

function test.to_abs_basic(t)
	local vps = {
		new_vp(0),
		new_vp(1),
		new_vp(2),
	}

	local veN2 = VisualEventsN2()
	local es2 = veN2:generate(vps, {-1, 1})

	local ve = VisualEvents()
	local es1 = ve:generate(vps, {-1, 1})
	es1 = ve:toAbsEvents(vps)

	t:tdeq(es1, es2)
end

function test.to_abs_negative(t)
	local vis = Visual()

	local vp_1 = vis:newPoint(Point(0))
	local vp_2 = vis:newPoint(Point(100))

	vp_1._velocity = Velocity(-1)
	vp_2._velocity = Velocity(1)

	vis:compute()

	local ve = VisualEvents()
	local events = ve:generate(vis.points, {-1, 1})
	t:eq(#events, 4)

	events = ve:toAbsEvents(vis.points)
	t:eq(#events, 6)

	local veN2 = VisualEventsN2()
	local es2 = veN2:generate(vis.points, {-1, 1})

	t:tdeq(events, es2)
end

local function rand_vel()
	return math.floor((math.random() - 0.5) * 2000) / 1000
end

function test.N2_validate(t)
	local vis = Visual()

	local time = 0
	for i = 1, 200 do
		local vp = vis:newPoint(Point(time))
		time = time + 100
		vp._velocity = Velocity(rand_vel(), rand_vel(), 1)
	end
	vis:compute()

	local veN2 = VisualEventsN2()
	local eventsN2 = veN2:generate(vis.points, {-1, 1})

	local ve = VisualEvents()
	local events = ve:generate(vis.points, {-1, 1})
	local abs_events = ve:toAbsEvents(vis.points)

	for _, e in ipairs(abs_events) do
		e.point_vt = e.point.visualTime
		e.point_at = e.point.point.absoluteTime
		e.point = nil
	end
	for _, e in ipairs(eventsN2) do
		e.point_vt = e.point.visualTime
		e.point_at = e.point.point.absoluteTime
		e.point = nil
	end

	t:eq(#abs_events, #eventsN2)
	-- t:tdeq(abs_events, eventsN2)

	eq_events(t, abs_events, eventsN2)
end

return test
