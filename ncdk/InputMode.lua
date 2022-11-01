local InputMode = {}

local mt = {__index = InputMode}

function InputMode:new(s)
	return setmetatable({}, mt):set(s)
end

setmetatable(InputMode, {__call = InputMode.new})

function InputMode:set(s)
	if type(s) == "string" then
		for inputCount, inputType in s:gmatch("([0-9]+)([a-z]+)") do
			self[inputType] = tonumber(inputCount)
		end
		assert(s == tostring(self))
	elseif type(s) == "table" then
		for inputType, inputCount in pairs(s) do
			self[inputType] = inputCount
		end
	end
	return self
end

local function sort(a, b)
	if a[2] ~= b[2] then
		return a[2] > b[2]
	end
	return a[1] < b[1]
end

function mt.__tostring(a)
	local inputs = {}
	for inputType, inputCount in pairs(a) do
		inputs[#inputs + 1] = {inputType, inputCount}
	end
	table.sort(inputs, sort)

	for i = #inputs * 2, 1, -2 do
		local input = inputs[i / 2]
		inputs[i] = input[1]
		inputs[i - 1] = input[2]
	end

	return table.concat(inputs)
end

function mt.__concat(a, b)
	return tostring(a) .. tostring(b)
end

function mt.__eq(a, b)
	return tostring(a) == tostring(b)
end

function mt.__le(a, b)
	for inputType, inputCount in pairs(a) do
		if b[inputType] ~= inputCount then
			return
		end
	end
	return true
end

return InputMode
