local class = require("class")
local math_util = require("math_util")
local VisualInterpolator = require("ncdk2.visual.VisualInterpolator")
local VisualEvents = require("ncdk2.visual.VisualEvents")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class ncdk2.Visual
---@operator call: ncdk2.Visual
---@field points ncdk2.VisualPoint[]
local Visual = class()

function Visual:new()
	self.interpolator = VisualInterpolator()
	self.events = VisualEvents()
	self.points = {}
end

---@type number
Visual.primaryTempo = 0

---@type "current"|"local"|"global"
Visual.tempoMultiplyTarget = "current"

---@param point ncdk2.Point
---@return ncdk2.VisualPoint
function Visual:newPoint(point)
	local vp = VisualPoint(point)
	table.insert(self.points, vp)
	return vp
end

---@return ncdk2.Velocity?
function Visual:getFirstVelocity()
	for _, vp in ipairs(self.points) do
		if vp._velocity then
			return vp._velocity
		end
	end
end

function Visual:compute()
	local points = self.points
	if #points == 0 then
		return
	end

	table.sort(points)

	local velocity = self:getFirstVelocity()

	---@type {[number]: number}
	local section_time = {}
	local section = 0

	local _tempo = 0  -- ok for first point

	local visualTime = 0
	local absoluteTime = points[1].point.absoluteTime
	for _, visualPoint in ipairs(points) do
		---@type ncdk2.Point|ncdk2.AbsolutePoint|ncdk2.MeasurePoint|ncdk2.IntervalPoint
		local point = visualPoint.point

		local _currentSpeed = self:multiply(velocity, _tempo)

		local interval = point.interval
		local tempo = point.tempo
		if tempo then
			_tempo = tempo.tempo
		end
		if point._stop then
			_tempo = 0
		end

		local _absoluteTime = point.absoluteTime
		visualTime = visualTime + (_absoluteTime - absoluteTime) * _currentSpeed
		absoluteTime = _absoluteTime

		local _velocity = visualPoint._velocity
		if _velocity then
			velocity = _velocity
		end
		visualPoint:setSpeeds(self:multiply(velocity, _tempo))

		local expand = visualPoint._expand
		if expand then
			local clearCurrentSpeed = velocity and velocity.currentSpeed or 1
			local duration = expand.duration * clearCurrentSpeed
			if tempo then
				duration = duration * tempo:getBeatDuration()
			elseif interval then
				duration = duration * interval:getBeatDuration()
			end
			if math.abs(duration) == math.huge then
				section_time[section] = visualTime
				section = section + math_util.sign(duration)
				visualTime = section_time[section] or visualTime
			else
				visualTime = visualTime + duration
			end
		end

		visualPoint.visualTime = visualTime
		visualPoint.section = section
	end

	local zero_vp = VisualPoint(Point(0))
	self.interpolator:interpolate(points, 1, zero_vp, "absolute")

	for _, vp in ipairs(points) do
		vp.visualTime = vp.visualTime - zero_vp.visualTime
	end
end

---@param velocity ncdk2.Velocity?
---@param tempo number
---@return number
---@return number
---@return number
function Visual:multiply(velocity, tempo)
	local currentSpeed, localSpeed, globalSpeed = 1, 1, 1
	if velocity then
		currentSpeed = velocity.currentSpeed
		localSpeed = velocity.localSpeed
		globalSpeed = velocity.globalSpeed
	end

	if self.primaryTempo == 0 then
		return currentSpeed, localSpeed, globalSpeed
	end

	local tempoMultiplier = tempo / self.primaryTempo

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

---@param range {[1]: number, [2]: number}
---@return ncdk2.VisualEvent[]
function Visual:generateEvents(range)
	return self.events:generate(self.points, range)
end

return Visual