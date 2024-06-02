local table_util = require("table_util")
local Visual = require("chartedit.Visual")
local Point = require("chartedit.Point")

local test = {}

function test.get_point(t)
	local vis = Visual()

	local p1 = Point()
	local p2 = Point()
	table_util.to_linked({p1, p2})

	local vp1 = vis:getPoint(p1)
	local vp2 = vis:getPoint(p2)

	t:tdeq(table_util.to_array(vp1), {vp1, vp2})
end

function test.create_before(t)
	local vis = Visual()

	local p = Point()
	local vp2 = vis:getPoint(p)
	local vp0 = vis:createBefore(vp2)
	t:eq(vis:getPoint(p), vp0)

	local vp1 = vis:createBefore(vp2)
	t:eq(vis:getPoint(p), vp0)

	t:tdeq(table_util.to_array(vp0), {vp0, vp1, vp2})
end

function test.create_after(t)
	local vis = Visual()

	local p = Point()
	local vp0 = vis:getPoint(p)
	local vp2 = vis:createAfter(vp0)
	t:eq(vis:getPoint(p), vp0)

	local vp1 = vis:createAfter(vp0)
	t:eq(vis:getPoint(p), vp0)

	t:tdeq(table_util.to_array(vp0), {vp0, vp1, vp2})
end

return test
