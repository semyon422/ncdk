local class = require("class")

---@class ncdk.ExpandData
---@operator call: ncdk.ExpandData
local ExpandData = class()

---@param duration ncdk.Fraction
function ExpandData:new(duration)
	self.duration = duration
end

---@param duration ncdk.Fraction
---@return boolean
function ExpandData:set(duration)
	local _duration = self.duration
	self.duration = duration
	return _duration ~= duration
end

---@param a ncdk.ExpandData
---@return string
function ExpandData.__tostring(a)
	return tostring(a.timePoint) .. "," .. a.duration
end

---@param a ncdk.ExpandData
---@param b ncdk.ExpandData
---@return boolean
function ExpandData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.ExpandData
---@param b ncdk.ExpandData
---@return boolean
function ExpandData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.ExpandData
---@param b ncdk.ExpandData
---@return boolean
function ExpandData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return ExpandData
