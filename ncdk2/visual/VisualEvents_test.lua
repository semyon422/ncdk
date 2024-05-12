local Velocity = require("ncdk2.visual.Velocity")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local VisualEvents = require("ncdk2.visual.VisualEvents")
local VisualEventsN2 = require("ncdk2.visual.VisualEventsN2")
local Visual = require("ncdk2.visual.Visual")

local test = {}

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

function test.negative(t)
	local vis = Visual()

	local vp_1 = vis:newPoint(Point(0))
	local vp_2 = vis:newPoint(Point(100))

	vp_1._velocity = Velocity(-1)
	vp_2._velocity = Velocity(1)

	vis:compute()

	local ve = VisualEvents()
	local events = ve:generate(vis.points, {-1, 1})

	t:eq(#events, 4)

	local order = {}

	local _offset = ve.startOffset
	local offset, vp, show

	for _, cvp in ipairs(vis.points) do
		offset, vp, show = ve:next(_offset, cvp.visualTime)
		while offset do
			_offset = offset
			table.insert(order, {vp.point.absoluteTime, show and 1 or -1})
			offset, vp, show = ve:next(offset, cvp.visualTime)
		end
	end

	offset, vp, show = ve:next(_offset, math.huge)
	while offset do
		_offset = offset
		table.insert(order, {vp.point.absoluteTime, show and 1 or -1})
		offset, vp, show = ve:next(offset, math.huge)
	end

	t:tdeq(order, {{0,1},{0,-1},{100,1},{100,-1},{0,1},{0,-1}})
end

function test.negative_globals(t)
	local vis = Visual()

	local vp_1 = vis:newPoint(Point(0))
	local vp_2 = vis:newPoint(Point(100))
	local vp_3 = vis:newPoint(Point(200))
	local vp_4 = vis:newPoint(Point(300))

	vp_1._velocity = Velocity(-1, 1, -1)
	vp_2._velocity = Velocity(1, 1, 1)
	vp_3._velocity = Velocity(-1, 1, -1)
	vp_4._velocity = Velocity(1, 1, 1)

	vis:compute()

	local ve = VisualEvents()
	local events = ve:generate(vis.points, {-1, 1})

	t:eq(#events, 8)

	-- local order = {}

	-- local _offset = ve.startOffset
	-- local offset, vp, show

	-- for _, cvp in ipairs(vis.points) do
	-- 	offset, vp, show = ve:next(_offset, cvp.visualTime)
	-- 	while offset do
	-- 		_offset = offset
	-- 		table.insert(order, {vp.point.absoluteTime, show and 1 or -1})
	-- 		offset, vp, show = ve:next(offset, cvp.visualTime)
	-- 	end
	-- end

	-- offset, vp, show = ve:next(_offset, math.huge)
	-- while offset do
	-- 	_offset = offset
	-- 	table.insert(order, {vp.point.absoluteTime, show and 1 or -1})
	-- 	offset, vp, show = ve:next(offset, math.huge)
	-- end

	-- t:tdeq(order, {{0,1},{0,-1},{100,1},{100,-1},{0,1},{0,-1}})
end

-- do return test end

local function rand_vel()
	return math.floor((math.random() - 0.5) * 2000) / 1000
end
local function rand_vel_mono()
	return math.floor(math.random() * 1000) / 1000
end

function test.N2_validate(t)
	local vis = Visual()

	local time = 0
	for i = 1, 4 do
		local vp = vis:newPoint(Point(time))
		time = time + 100
		-- vp._velocity = Velocity(rand_vel(), rand_vel(), 1)
		-- vp._velocity = Velocity(rand_vel(), i, 1)
		-- vp._velocity = Velocity((-1) ^ i, i)
		vp._velocity = Velocity((-1) ^ i, 1, (-1) ^ i)
		vp.index = i
	end
	vis:compute()

	local veN2 = VisualEventsN2()
	print()
	print("---------------------------------------------------")
	local eventsN2 = veN2:generate(vis.points, {-1, 1})

	local orderN2 = {}
	for i, e in ipairs(eventsN2) do
		table.insert(orderN2, {e.point.index, e.action})
	end

	local ve = VisualEvents()
	local events = ve:generate(vis.points, {-1, 1})

	local order = {}

	local _offset = ve.startOffset  -- !!!
	for _, cvp in ipairs(vis.points) do
		local offset, vp, show = ve:next(_offset, cvp.visualTime)
		while offset do
			_offset = offset
			table.insert(order, {vp.index, show and 1 or -1})
			offset, vp, show = ve:next(offset, cvp.visualTime)
		end
	end

	local last_currentSpeed = vis.points[#vis.points].currentSpeed  -- !!!
	local offset, vp, show = ve:next(_offset, last_currentSpeed / 0)
	while offset do
		_offset = offset
		table.insert(order, {vp.index, show and 1 or -1})
		offset, vp, show = ve:next(offset, last_currentSpeed / 0)
	end

	t:eq(#orderN2, #order)

	-- print("----------------")
	-- print(#events)
	-- print(require("stbl").encode(orderN2))
	-- print(require("stbl").encode(order))
	-- -- assert(#events == #eventsN2, #eventsN2 .. " " .. #events)

	-- local err = 0
	-- for i = 1, #events do
	-- 	if math.abs(eventsN2[i].time) ~= math.huge then
	-- 		err = math.abs(eventsN2[i].time - events[i].time)
	-- 	end
	-- end
	-- t:lt(err / #events, 1e-6)

	-- t:tdeq(events, eventsN2)
end

return test
