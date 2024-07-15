local class = require("class")
local Velocity = require("ncdk2.visual.Velocity")
local Expand = require("ncdk2.visual.Expand")

---@class ncdk2.Restorer
---@operator call: ncdk2.Restorer
local Restorer = class()

---@param vps ncdk2.VisualPoint[]
function Restorer:restore(vps)
	for _, vp in ipairs(vps) do
		vp._velocity = nil
		vp._expand = nil
	end

	for i = 1, #vps - 1 do
		local vp = vps[i]
		local next_vp = vps[i + 1]

		---@type ncdk2.Interval?
		local interval = vp.point.interval
		---@type ncdk2.Tempo?
		local tempo = vp.point.tempo

		local dvt = next_vp.visualTime - vp.visualTime
		local dat = next_vp.point.absoluteTime - vp.point.absoluteTime
		if dat > 0 then
			vp._velocity = Velocity(dvt / dat)
		else
			local duration = dvt
			if tempo then
				duration = duration / tempo:getBeatDuration()
			elseif interval then
				duration = duration / interval:getBeatDuration()
			end
			vp._expand = Expand(duration)
		end
	end
end

return Restorer
