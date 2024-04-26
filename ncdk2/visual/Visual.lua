local class = require("class")

---@class ncdk2.Visual
---@operator call: ncdk2.Visual
local Visual = class()

Visual.primaryTempo = 0
Visual.tempoMultiplyTarget = "current"  -- "current" | "local" | "global"

---@param visualPoints ncdk2.VisualPoint[]
---@return ncdk2.Velocity?
function Visual:getFirstVelocity(visualPoints)
	for _, vp in ipairs(visualPoints) do
		if vp._velocity then
			return vp._velocity
		end
	end
end

---@param visualPoints ncdk2.VisualPoint[]
function Visual:compute(visualPoints)
	local velocity = self:getFirstVelocity(visualPoints)
	local primaryTempo = self.primaryTempo

	local visualTime = 0
	local section = 0
	local currentAbsoluteTime = 0
	for _, visualPoint in ipairs(visualPoints) do
		local point = visualPoint.point
		local time = point.absoluteTime

		---@type ncdk2.Tempo?
		local tempo = point.tempo
		---@type ncdk2.Stop?
		local stop = point._stop
		---@type ncdk2.Interval?
		local interval = point.interval

		local tempoMultiplier = 1
		if primaryTempo ~= 0 then
			if stop then
				tempoMultiplier = 0
			elseif tempo then
				tempoMultiplier = tempo.tempo / primaryTempo
			end
		end

		local currentSpeed, localSpeed, globalSpeed =
			self:multiply(velocity, tempoMultiplier)

		visualTime = visualTime + (time - currentAbsoluteTime) * currentSpeed
		currentAbsoluteTime = time

		local _velocity = visualPoint._velocity
		if _velocity then
			velocity = _velocity
		end
		currentSpeed = self:multiply(velocity, tempoMultiplier)

		local expand = visualPoint._expand
		if expand then
			local duration = expand.duration * currentSpeed
			if tempo then
				duration = duration * tempo:getBeatDuration()
			elseif interval then
				duration = duration * interval:getBeatDuration()
			end
			if math.abs(duration) == math.huge then
				section = section + 1
			else
				visualTime = visualTime + duration
			end
		end

		visualPoint.velocity = velocity

		visualPoint.visualTime = visualTime
		visualPoint.section = section
		visualPoint.currentSpeed = currentSpeed
		visualPoint.localSpeed = localSpeed
		visualPoint.globalSpeed = globalSpeed
	end
end

---@param velocity ncdk2.Velocity?
---@param tempoMultiplier number
---@return number
---@return number
---@return number
function Visual:multiply(velocity, tempoMultiplier)
	local currentSpeed, localSpeed, globalSpeed = 1, 1, 1
	if velocity then
		currentSpeed = velocity.currentSpeed
		localSpeed = velocity.localSpeed
		globalSpeed = velocity.globalSpeed
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
