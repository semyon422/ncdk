local class = require("class")

---@class ncdk.VelocityData
---@operator call: ncdk.VelocityData
local VelocityData = class()

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1

---@param currentSpeed number?
---@param localSpeed number?
---@param globalSpeed number?
function VelocityData:new(currentSpeed, localSpeed, globalSpeed)
	self:set(currentSpeed, localSpeed, globalSpeed)
end

---@param currentSpeed number?
---@param localSpeed number?
---@param globalSpeed number?
---@return boolean
function VelocityData:set(currentSpeed, localSpeed, globalSpeed)
	local _currentSpeed = self.currentSpeed
	self.currentSpeed = currentSpeed
	self.localSpeed = localSpeed
	self.globalSpeed = globalSpeed
	return _currentSpeed ~= currentSpeed
end

---@param a ncdk.VelocityData
---@return string
function VelocityData.__tostring(a)
	return ("%s,%s,%s,%s"):format(a.timePoint, a.currentSpeed, a.localSpeed, a.globalSpeed)
end

---@param a ncdk.VelocityData
---@param b ncdk.VelocityData
---@return boolean
function VelocityData.__eq(a, b)
	return a.timePoint == b.timePoint
end

---@param a ncdk.VelocityData
---@param b ncdk.VelocityData
---@return boolean
function VelocityData.__lt(a, b)
	return a.timePoint < b.timePoint
end

---@param a ncdk.VelocityData
---@param b ncdk.VelocityData
---@return boolean
function VelocityData.__le(a, b)
	return a.timePoint <= b.timePoint
end

return VelocityData
