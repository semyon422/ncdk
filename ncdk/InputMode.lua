ncdk.InputMode = {}
local InputMode = ncdk.InputMode

ncdk.InputMode_metatable = {}
local InputMode_metatable = ncdk.InputMode_metatable
InputMode_metatable.__index = InputMode

InputMode.new = function(self)
	local inputMode = {}
	
	inputMode.inputData = {}
	
	setmetatable(inputMode, InputMode_metatable)
	
	return inputMode
end

InputMode.setInput = function(self, inputType, inputIndex, binding)
	self.inputData[inputType] = self.inputData[inputType] or {}
	self.inputData[inputType][inputIndex] = binding
end

InputMode.getInput = function(self, inputType, inputIndex)
	return self.inputData[inputType] and self.inputData[inputType][inputIndex]
end

InputMode.getString = function(self)
	local inputMaxIndex = {}
	for inputType, data in pairs(self.inputData) do
		for inputIndex in pairs(data) do
			inputMaxIndex[inputType] = inputMaxIndex[inputType] or 0
			if inputIndex > inputMaxIndex[inputType] then
				inputMaxIndex[inputType] = inputIndex
			end
		end
	end
	
	local inputs = {}
	for inputType, inputIndex in pairs(inputMaxIndex) do
		if inputType ~= "auto" then
			table.insert(inputs, {inputType, inputIndex})
		end
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