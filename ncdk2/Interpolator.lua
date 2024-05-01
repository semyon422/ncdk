local class = require("class")

---@class ncdk2.Interpolator
---@operator call: ncdk2.Interpolator
local Interpolator = class()

---@generic T
---@param p T
---@return T
local function ident(p)
	return p
end

---@generic T
---@param list {compare: fun(self: T, p: T)}[]
---@param index number
---@param p {compare: fun(self: T, p: T)}
---@param ext (fun(p: T): T)?
---@return number
function Interpolator:getBaseIndex(list, index, p, ext)
	ext = ext or ident

	index = math.min(math.max(index, 1), #list)

	local _p = list[index]
	if p == _p or ext(p):compare(ext(_p)) and index == 1 then
		-- skip
	elseif ext(_p):compare(ext(p)) then
		local next_vp = list[index + 1]
		while next_vp do
			if not ext(p):compare(ext(next_vp)) then
				index = index + 1
				next_vp = list[index + 1]
			else
				break
			end
		end
	elseif ext(p):compare(ext(_p)) then
		index = index - 1
		local prev_vp = list[index]
		while prev_vp do
			if ext(p):compare(ext(prev_vp)) then
				index = index - 1
				prev_vp = list[index]
			else
				break
			end
		end
	end

	return math.max(index, 1)
end

return Interpolator
