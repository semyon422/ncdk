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

local function eq(p, _p, ext)
	return not ext(p):compare(ext(_p)) and not ext(_p):compare(ext(p))
end

local function lt(p, _p, ext)
	return ext(p):compare(ext(_p))
end

local function lte(p, _p, ext)
	return not ext(_p):compare(ext(p))
end

---@generic T
---@param list {compare: fun(self: T, p: T)}[]
---@param index number
---@param p {compare: fun(self: T, p: T)}
---@param ext (fun(p: T): T)?
function Interpolator:isOk(list, index, p, ext)
	if #list == 1 then
		return true
	end

	ext = ext or ident
	local _p = list[index]
	local next_p = list[index + 1]
	local prev_p = list[index - 1]

	if prev_p and not lt(prev_p, p, ext) then
		return
	end
	return
		not prev_p and lt(p, _p, ext) or
		eq(_p, p, ext) or
		lt(_p, p, ext) and (not next_p or lt(p, next_p, ext))
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

	local dir = lte(p, list[index], ext) and -1 or 1
	while not self:isOk(list, index, p, ext) do
		index = index + dir
		if index == 0 or index == #list + 1 then
			error("invalid index")
		end
	end

	return index
end

return Interpolator
