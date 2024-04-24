local class = require("class")

---@class ncdk2.VelocityData
---@operator call: ncdk2.VelocityData
local VelocityData = class()

VelocityData.currentSpeed = 1
VelocityData.localSpeed = 1
VelocityData.globalSpeed = 1

---@param currentSpeed number
---@param localSpeed number
---@param globalSpeed number
function VelocityData:new(currentSpeed, localSpeed, globalSpeed)
	self.currentSpeed = currentSpeed
	self.localSpeed = localSpeed
	self.globalSpeed = globalSpeed
end

---@param a ncdk2.VelocityData
---@return string
function VelocityData.__tostring(a)
	return ("VelocityData(%s,%s,%s)"):format(a.currentSpeed, a.localSpeed, a.globalSpeed)
end

return VelocityData
