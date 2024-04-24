local class = require("class")

---@class ncdk2.Visual
---@operator call: ncdk2.Visual
local Visual = class()

Visual.primaryTempo = 0
Visual.tempoMultiplyTarget = "current"  -- "current" | "local" | "global"

---@param visualTimePoints ncdk2.VisualTimePoint[]
---@return ncdk2.VelocityData?
function Visual:getFirstVelocityData(visualTimePoints)
	for _, tp in ipairs(visualTimePoints) do
		if tp._velocityData then
			return tp._velocityData
		end
	end
end

---@param visualTimePoints ncdk2.VisualTimePoint[]
function Visual:compute(visualTimePoints)
	local velocityData = self:getFirstVelocityData(visualTimePoints)
	local primaryTempo = self.primaryTempo

	local visualTime = 0
	local visualSection = 0
	local currentAbsoluteTime = 0
	for _, visualTimePoint in ipairs(visualTimePoints) do
		local timePoint = visualTimePoint.timePoint
		local time = timePoint.absoluteTime

		---@type ncdk2.TempoData?
		local tempoData = timePoint.tempoData
		---@type ncdk2.StopData?
		local stopData = timePoint._stopData
		---@type ncdk2.IntervalData?
		local intervalData = timePoint.intervalData

		local tempoMultiplier = 1
		if primaryTempo ~= 0 then
			if stopData then
				tempoMultiplier = 0
			elseif tempoData then
				tempoMultiplier = tempoData.tempo / primaryTempo
			end
		end

		local currentSpeed, localSpeed, globalSpeed =
			self:multiply(velocityData, tempoMultiplier)

		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed
		currentAbsoluteTime = time

		local _velocityData = visualTimePoint._velocityData
		if _velocityData then
			velocityData = _velocityData
		end
		currentSpeed = self:multiply(velocityData, tempoMultiplier)

		local expandData = visualTimePoint._expandData
		if expandData then
			local duration = expandData.duration * currentSpeed
			if tempoData then
				duration = duration * tempoData:getBeatDuration()
			elseif intervalData then
				duration = duration * intervalData:getBeatDuration()
			end
			if math.abs(duration) == math.huge then
				visualSection = visualSection + 1
			else
				visualTime = visualTime + duration
			end
		end

		visualTimePoint.velocityData = velocityData

		visualTimePoint.visualTime = visualTime
		visualTimePoint.visualSection = visualSection
		visualTimePoint.currentSpeed = currentSpeed
		visualTimePoint.localSpeed = localSpeed
		visualTimePoint.globalSpeed = globalSpeed
	end
end

---@param velocityData ncdk2.VelocityData?
---@param tempoMultiplier number
---@return number
---@return number
---@return number
function Visual:multiply(velocityData, tempoMultiplier)
	local currentSpeed, localSpeed, globalSpeed = 1, 1, 1
	if velocityData then
		currentSpeed = velocityData.currentSpeed
		localSpeed = velocityData.localSpeed
		globalSpeed = velocityData.globalSpeed
	end

	local target = self.tempoMultiplyTarget
	if target == "current" then
		currentSpeed = currentSpeed * tempoMultiplier
	elseif target == "local" then
		localSpeed = localSpeed * tempoMultiplier
	elseif target == "global" then
		globalSpeed = globalSpeed * tempoMultiplier
	end

	return currentSpeed, localSpeed, globalSpeed
end

return Visual
