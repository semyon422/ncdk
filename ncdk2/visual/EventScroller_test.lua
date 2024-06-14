local EventScroller = require("ncdk2.visual.EventScroller")

local test = {}

function test.basic(t)
	local events = {
		{time = -math.huge, action = 1, point = -math.huge},
		{time = 1, action = 1, point = 1},
		{time = math.huge, action = 1, point = math.huge},
	}

	local es = EventScroller(events)

	local res = {}
	es:scroll(0, function(vp, action)
		table.insert(res, vp)
	end)
	t:tdeq(res, {-math.huge})

	res = {}
	es:scroll(0, function(vp, action)
		table.insert(res, vp)
	end)
	t:tdeq(res, {})

	res = {}
	es:scroll(1, function(vp, action)
		table.insert(res, vp)
	end)
	t:tdeq(res, {1})

	res = {}
	es:scroll(2, function(vp, action)
		table.insert(res, vp)
	end)
	t:tdeq(res, {})
end

return test
