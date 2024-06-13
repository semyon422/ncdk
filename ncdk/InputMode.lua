local class = require("class")

---@class ncdk.InputMode
---@operator call: ncdk.InputMode
local InputMode = class()

---@param s string|table?
function InputMode:new(s)
	self:set(s)
end

---@param s string|table?
---@return ncdk.InputMode
function InputMode:set(s)
	if type(s) == "string" then
		for inputCount, inputType in s:gmatch("([0-9]+)([a-z]+)") do
			self[inputType] = tonumber(inputCount)
		end
		if s ~= tostring(self) then
			error(("invalid InputMode string (%s expected, got %s)"):format(tostring(self), s))
		end
	elseif type(s) == "table" then
		for inputType, inputCount in pairs(s) do
			self[inputType] = inputCount
		end
	end
	return self
end

---@param s string
---@return string?
---@return number?
function InputMode:splitInput(s)
	local inputType, inputIndex = s:match("^(.-)(%d+)$")
	if not inputType then
		return
	end
	return inputType, tonumber(inputIndex)
end

---@return number
function InputMode:getColumns()
	local columns = 0
	for _, inputCount in pairs(self) do
		columns = columns + inputCount
	end
	return columns
end

---@param a table
---@param b table
---@return boolean
local function sort(a, b)
	if a[2] ~= b[2] then
		return a[2] > b[2]
	end
	return a[1] < b[1]
end

---@return table
function InputMode:getList()
	local inputs = {}
	for inputType, inputCount in pairs(self) do
		inputs[#inputs + 1] = {inputType, inputCount}
	end
	table.sort(inputs, sort)
	return inputs
end

---@return table
function InputMode:getInputs()
	local list = self:getList()
	local inputs = {}
	for _, input in ipairs(list) do
		for i = 1, input[2] do
			table.insert(inputs, input[1] .. i)
		end
	end
	return inputs
end

---@return table
function InputMode:getInputMap()
	local inputs = self:getList()

	local map = {}
	for i = 1, #inputs do
		for j = 1, inputs[i][2] do
			map[#map + 1] = {inputs[i][1], j}
			map[inputs[i][1] .. j] = #map
		end
	end

	return map
end

---@param a ncdk.InputMode
---@return string
function InputMode.__tostring(a)
	local inputs = a:getList()

	for i = #inputs * 2, 1, -2 do
		local input = inputs[i / 2]
		inputs[i] = input[1]
		inputs[i - 1] = input[2]
	end

	return table.concat(inputs)
end

---@param a any
---@param b any
---@return string
function InputMode.__concat(a, b)
	return tostring(a) .. tostring(b)
end

---@param a ncdk.InputMode
---@param b ncdk.InputMode
---@return boolean
function InputMode.__eq(a, b)
	return tostring(a) == tostring(b)
end

---@param a ncdk.InputMode
---@param b ncdk.InputMode
---@return boolean
function InputMode.__le(a, b)
	for inputType, inputCount in pairs(a) do
		if b[inputType] ~= inputCount then
			return false
		end
	end
	return true
end

return InputMode
