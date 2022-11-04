local SignatureTable = {}

local mt = {__index = SignatureTable}

SignatureTable.mode = "short"

function SignatureTable:new(defaultSignature)
	local signatureTable = {}

	signatureTable.data = {}
	signatureTable.signatures = {}
	signatureTable.defaultSignature = assert(defaultSignature)

	return setmetatable(signatureTable, mt)
end

function SignatureTable:setMode(mode)
	assert(mode == "long" or mode == "short", "Wrong signature mode")
	self.mode = mode
end

function SignatureTable:setSignature(measureIndex, signature)
	self.data[measureIndex] = signature
	self.needSort = true
end

function SignatureTable:getSignature(measureIndex)
	if not next(self.data) then
		return self.defaultSignature
	end
	if self.mode == "short" then
		return self.data[measureIndex] or self.defaultSignature
	end

	if self.needSort then
		self:sort()
		self.needSort = false
	end

	local signatures = self.signatures
	local currentMeasureIndex, currentSignature = unpack(signatures[self.position])

	if measureIndex == currentMeasureIndex then
		return currentSignature
	end

	local step = measureIndex - currentMeasureIndex > 0 and 1 or -1
	local to = step == -1 and 1 or #signatures
	for i = self.position, to, step do
		local measureIndex1, signature = unpack(signatures[i])
		local measureIndex2 = signatures[i + 1] and signatures[i + 1][1] or math.huge
		if measureIndex >= measureIndex1 and measureIndex < measureIndex2 then
			self.position = i
			return signature
		end
	end

	return self.defaultSignature
end

function SignatureTable:sort()
	local signatures = {}
	for measureIndex, signature in pairs(self.data) do
		table.insert(signatures, {measureIndex, signature})
	end
	table.sort(signatures, function(a, b) return a[1] < b[1] end)
	self.signatures = signatures
	self.position = 1
end

return SignatureTable
