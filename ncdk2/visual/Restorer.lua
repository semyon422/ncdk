local class = require("class")
local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")

---@class ncdk2.Restorer
---@operator call: ncdk2.Restorer
local Restorer = class()

Restorer.velocity_treshold = 10

---@param vps ncdk2.VisualPoint[]
function Restorer:restore(vps)
	for _, vp in ipairs(vps) do
		vp._velocity = nil
		vp._expand = nil
	end

	---@type number
	local vel

	for i = 1, #vps - 1 do
		local vp = vps[i]
		local next_vp = vps[i + 1]

		local dvt = next_vp.visualTime - vp.visualTime
		local dat = next_vp.point.absoluteTime - vp.point.absoluteTime

		local cur_vel = dvt / dat

		---@type ncdk2.Interval?
		local interval = next_vp.point.interval
		if interval then
			dvt = dvt / interval:getBeatDuration()
		end

		if dat == 0 and dvt > 0 then
			vp._expand = Expand(dvt)
		elseif dat > 0 and cur_vel ~= vel then
			if cur_vel > self.velocity_treshold then
				vp._velocity = Velocity(0)
				vp._expand = Expand(dvt)
				vel = 0
			else
				vp._velocity = Velocity(cur_vel)
				vel = cur_vel
			end
		end
	end
end

return Restorer
