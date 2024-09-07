local lookupValueToCharacter = buffer.create(64)
local lookupCharacterToValue = buffer.create(256)

local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local padding = string.byte("=")

for index = 1, 64 do
	local value = index - 1
	local character = string.byte(alphabet, index)
	buffer.writeu8(lookupValueToCharacter, value, character)
	buffer.writeu8(lookupCharacterToValue, character, value)
end

local function writeEncodedChars(output, outputIndex, values)
	for i, value in ipairs(values) do
		buffer.writeu8(output, outputIndex + (i - 1), buffer.readu8(lookupValueToCharacter, value))
	end
end

local function encode(input: buffer): buffer
	local inputLength = buffer.len(input)
	local inputChunks = math.ceil(inputLength / 3)
	local outputLength = inputChunks * 4
	local output = buffer.create(outputLength)

	for chunkIndex = 1, inputChunks - 1 do
		local inputIndex = (chunkIndex - 1) * 3
		local outputIndex = (chunkIndex - 1) * 4

		local chunk = bit32.byteswap(buffer.readu32(input, inputIndex))
		local values = {
			bit32.rshift(chunk, 26),
			bit32.band(bit32.rshift(chunk, 20), 0b111111),
			bit32.band(bit32.rshift(chunk, 14), 0b111111),
			bit32.band(bit32.rshift(chunk, 8), 0b111111)
		}

		writeEncodedChars(output, outputIndex, values)
	end

	local inputRemainder = inputLength % 3
	local finalIndex = outputLength - 4

	if inputRemainder > 0 then
		local chunk = 0
		if inputRemainder == 1 then
			chunk = buffer.readu8(input, inputLength - 1)
			local values = {
				bit32.rshift(chunk, 2),
				bit32.band(bit32.lshift(chunk, 4), 0b111111),
				padding, padding
			}
			writeEncodedChars(output, finalIndex, values)
		elseif inputRemainder == 2 then
			chunk = bit32.bor(
				bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
				buffer.readu8(input, inputLength - 1)
			)
			local values = {
				bit32.rshift(chunk, 10),
				bit32.band(bit32.rshift(chunk, 4), 0b111111),
				bit32.band(bit32.lshift(chunk, 2), 0b111111),
				padding
			}
			writeEncodedChars(output, finalIndex, values)
		end
	else
		local chunk = bit32.bor(
			bit32.lshift(buffer.readu8(input, inputLength - 3), 16),
			bit32.lshift(buffer.readu8(input, inputLength - 2), 8),
			buffer.readu8(input, inputLength - 1)
		)
		local values = {
			bit32.rshift(chunk, 18),
			bit32.band(bit32.rshift(chunk, 12), 0b111111),
			bit32.band(bit32.rshift(chunk, 6), 0b111111),
			bit32.band(chunk, 0b111111)
		}
		writeEncodedChars(output, finalIndex, values)
	end

	return output
end

return encode
