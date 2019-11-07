local InputMode = {}

local InputMode_metatable = {}
InputMode_metatable.__index = InputMode

InputMode.new = function(self)
	local inputMode = {}
	
	inputMode.data = {}
	
	setmetatable(inputMode, InputMode_metatable)
	
	return inputMode
end

InputMode.setInputCount = function(self, inputType, inputCount)
	self.data[inputType] = tonumber(inputCount)
end

InputMode.getInputCount = function(self, inputType)
	return self.data[inputType] or 0
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
			return a[1] < b [1]
		end
	end)
	for index, input in ipairs(inputs) do
		inputs[index] = input[2] .. input[1]
	end
	
	return table.concat(inputs)
end

InputMode.setString = function(self, inputModeString)
	for inputCount, inputType in inputModeString:gmatch("([0-9]+)([a-z]+)") do
		self:setInputCount(inputType, inputCount)
	end
	assert(inputModeString == self:getString())
	return self
end

InputMode_metatable.__eq = function(a, b)
	return a:getString() == b:getString()
end

InputMode_metatable.__le = function(a, b)
	for inputType, inputCount in pairs(a.data) do
		if b:getInputCount(inputType) ~= inputCount then
			return
		end
	end
	return true
end

return InputMode
