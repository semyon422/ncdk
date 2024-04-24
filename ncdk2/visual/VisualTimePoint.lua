local class = require("class")

---@class ncdk2.VisualTimePoint
---@operator call: ncdk2.VisualTimePoint
---@field _expandData ncdk2.ExpandData?
---@field _velocityData ncdk2.VelocityData?
---@field velocityData ncdk2.VelocityData?
local VisualTimePoint = class()

VisualTimePoint.visualTime = 0
VisualTimePoint.visualSection = 0
VisualTimePoint.currentSpeed = 1
VisualTimePoint.localSpeed = 1
VisualTimePoint.globalSpeed = 1

---@param timePoint ncdk2.TimePoint
function VisualTimePoint:new(timePoint)
	self.timePoint = timePoint
end

---@param vtp ncdk2.VisualTimePoint
---@return number
function VisualTimePoint:getVisualTime(vtp)
	if self.visualSection ~= vtp.visualSection then
		return (self.visualSection - vtp.visualSection) / 0
	end
	local globalSpeed = vtp.globalSpeed
	local localSpeed = self.localSpeed
	return (self.visualTime - vtp.visualTime) * globalSpeed * localSpeed + vtp.absoluteTime
end

---@param vtp ncdk2.VisualTimePoint
---@return boolean
function VisualTimePoint:compare(vtp)
	if self.visualSection == vtp.visualSection then
		return self.visualTime < vtp.visualTime
	end
	return self.visualSection < vtp.visualSection
end

---@param a ncdk2.VisualTimePoint
---@return string
function VisualTimePoint.__tostring(a)
	return ("VisualTimePoint(%s)"):format(a.timePoint)
end

return VisualTimePoint
