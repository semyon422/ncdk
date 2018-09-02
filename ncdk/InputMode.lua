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

InputMode.setInputFill = function(self, inputType, inputIndex, binding)
	self.inputData[inputType] = self.inputData[inputType] or {}
	self.inputData[inputType][inputIndex] = binding
	
	for i = 1, inputIndex - 1 do
		self.inputData[inputType][i] = self.inputData[inputType][i] or true
	end
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
			table.insert(inputs, inputIndex .. inputType)
		end
	end
	table.sort(inputs, function(a, b) return a > b end)
	
	return table.concat(inputs)
end

InputMode_metatable.__le = function(a, b)
	for inputType, inputTypeData in pairs(a.inputData) do
		if inputType ~= "auto" then
			for inputIndex in pairs(inputTypeData) do
				if not (b.inputData[inputType] and b.inputData[inputType][inputIndex]) then
					return
				end
			end
		end
	end
	
	return true
end

InputMode_metatable.__eq = function(a, b)
	return a <= b and b <= a
end