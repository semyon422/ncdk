ncdk.InputMode = {}
local InputMode = ncdk.InputMode

ncdk.InputMode_metatable = {}
local InputMode_metatable = ncdk.InputMode_metatable
InputMode_metatable.__index = InputMode

InputMode.new = function(self)
	local inputMode = {}
	
	inputMode.data = {}
	
	setmetatable(inputMode, InputMode_metatable)
	
	return inputMode
end

InputMode.setInputCount = function(self, inputType, inputCount)
	self.data[inputType] = inputCount
end

InputMode.getString = function(self)
	local inputs = {}
	for inputType, inputCount in pairs(self.data) do
		inputs[#inputs + 1] = {inputType, inputCount}
	end
	
	table.sort(inputs, function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		else
			return a[1] > b [1]
		end
	end)
	for index, input in ipairs(inputs) do
		inputs[index] = input[2] .. input[1]
	end
	
	return table.concat(inputs)
end

InputMode_metatable.__eq = function(a, b)
	return a:getString() == b:getString()
end