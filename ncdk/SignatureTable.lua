local SignatureTable = {}

local mt = {__index = SignatureTable}

SignatureTable.mode = "short"

function SignatureTable:new(defaultSignature)
	local signatureTable = {}

	signatureTable.data = {}
	signatureTable.needSort = true
	signatureTable.defaultSignature = assert(defaultSignature)

	return setmetatable(signatureTable, mt)
end

function SignatureTable:setSignature(measureIndex, signature)
	self.data[measureIndex] = signature
	self.needSort = true
end

function SignatureTable:getSignature(measureIndex)
	if not next(self.data) then
		return self.defaultSignature
	end
	if self.mode == "long" then
		if self.needSort then
			self.iterator = self:getIteraator()
		end
		local lastMeasureIndex = self.iterator.signatures[self.iterator.counter][1]
		local lastSignature
		if measureIndex > lastMeasureIndex then
			for currentMeasureIndex, signature in self.iterator.next do
				if measureIndex >= currentMeasureIndex then
					lastSignature = signature
				else
					break
				end
			end
		elseif measureIndex < lastMeasureIndex then
			for currentMeasureIndex, signature in self.iterator.prev do
				if measureIndex <= currentMeasureIndex then
					lastSignature = signature
				else
					break
				end
			end
		else
			lastSignature = self.iterator.signatures[self.iterator.counter][2]
		end
		return lastSignature or self.defaultSignature
	else
		return self.data[measureIndex] or self.defaultSignature
	end
end

function SignatureTable:setMode(mode)
	if mode ~= "long" and mode ~= "short" then
		error("Wrong signature mode")
	end
	self.mode = mode
end

local function sort(a, b)
	return a[1] < b[1]
end

function SignatureTable:getIteraator()
	local signatures = {}
	for measureIndex, signature in pairs(self.data) do
		signatures[#signatures + 1] = {measureIndex, signature}
	end
	table.sort(signatures, sort)

	local iterator = {}
	iterator.counter = 1
	iterator.signatures = signatures
	function iterator.next()
		local data = signatures[iterator.counter]
		if not data then return end

		local measureIndex, signature = data[1], data[2]
		iterator.counter = iterator.counter + 1

		return measureIndex, signature
	end
	function iterator.prev()
		local data = signatures[iterator.counter - 1]
		if not data then return end

		local measureIndex, signature = data[1], data[2]
		iterator.counter = iterator.counter - 1

		return measureIndex, signature
	end

	return iterator
end

return SignatureTable
