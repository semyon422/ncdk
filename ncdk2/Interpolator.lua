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
		return index
	end

	if ext(_p):compare(ext(p)) then
		while list[index + 1] and not ext(p):compare(ext(list[index + 1])) do
			index = index + 1
		end
		return index
	end

	while list[index] and ext(p):compare(ext(list[index])) do
		index = index - 1
	end

	return math.max(index, 1)
end

return Interpolator
