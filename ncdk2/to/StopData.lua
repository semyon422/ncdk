local class = require("class")

---@class ncdk2.StopData
---@operator call: ncdk2.StopData
local StopData = class()

---@param duration number|ncdk.Fraction
---@param isAbsolute boolean?
function StopData:new(duration, isAbsolute)
	self.duration = duration
	self.isAbsolute = isAbsolute
end

---@param a ncdk.StopData
---@return string
function StopData.__tostring(a)
	return ("StopData(%s)"):format(a.duration)
end

return StopData
