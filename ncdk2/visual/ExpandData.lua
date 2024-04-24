local class = require("class")

---@class ncdk2.ExpandData
---@operator call: ncdk2.ExpandData
local ExpandData = class()

ExpandData.duration = 0

---@param duration number
function ExpandData:new(duration)
	self.duration = duration
end

---@param a ncdk2.ExpandData
---@return string
function ExpandData.__tostring(a)
	return ("ExpandData(%s)"):format(a.duration)
end

return ExpandData
