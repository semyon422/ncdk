local class = require("class")
local math_util = require("math_util")
local Fraction = require("ncdk.Fraction")

---@class ncdk2.TempoConnector
---@operator call: ncdk2.TempoConnector
local TempoConnector = class()

---@param denom number
---@param merge_time number
function TempoConnector:new(denom, merge_time)
	self.denom = denom
	self.merge_time = merge_time
end

---@param o_1 number
---@param l_1 number
---@param o_2 number
---@return ncdk.Fraction
---@return boolean
function TempoConnector:connect(o_1, l_1, o_2)
	local duration = o_2 - o_1
	local beats = duration / l_1

	local merge_time = self.merge_time

	local _beats = math_util.round(beats)
	if math.abs(_beats * l_1 - duration) <= merge_time then
		return Fraction(_beats), false
	end

	return Fraction(beats, self.denom, "floor"), true
end

return TempoConnector
