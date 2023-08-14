local class = require("class")

local LineSection = class()

function LineSection:new()
	self.data = {}
end

local function objs_sort(a, b)
	if a[1] ~= b[1] then
		return a[1] < b[1]
	end
	return a[2] > b[2]
end

function LineSection:add(a, b, sub, noUpdate)
	local data = self.data

	local mul = sub and -1 or 1
	table.insert(data, {a, 1 * mul})
	table.insert(data, {b, -1 * mul})

	if noUpdate then
		return
	end

	self:update()
end

function LineSection:sub(a, b)
	self:add(a, b, true)
end

function LineSection:update()
	local data = self.data

	table.sort(data, objs_sort)

	local _data = {}
	local level = 0
	local _head
	for _, t in ipairs(data) do
		_head = _head or t[1]
		level = level + t[2]
		if level == 0 then
			if t[2] == -1 then
				table.insert(_data, {_head, 1})
				table.insert(_data, {t[1], -1})
			end
			_head = nil
		end
	end

	self.data = _data

	for i = 1, #self do
		self[i] = nil
	end
	for i = 1, #_data do
		self[i] = _data[i][1]
	end
end

local function max(a, b)
	return a >= b and a or b
end

local function min(a, b)
	return a <= b and a or b
end

function LineSection:over(a, b, exclusive)
	for i = 1, #self, 2 do
		local l, r = max(a, self[i]), min(b, self[i + 1])
		if exclusive and l < r or not exclusive and l <= r then
			return true
		end
	end
	return false
end

function LineSection:intersect(c, d)
	local ls = LineSection()
	for i = 1, #self, 2 do
		local a, b = self[i], self[i + 1]
		local f, g = max(a, c), min(b, d)
		if f <= g then
			ls:add(f, g, false, true)
		end
	end
	ls:update()
	return ls
end

return LineSection
