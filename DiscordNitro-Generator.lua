local Strings = string.split('aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ', '')
function generateNitro(howMuch)
	local completedCodes = {}
	for i = 1, howMuch do 
		local completedNitro = ''
		for i = 1, 16 do 
			completedNitro = completedNitro .. Strings[math.random(1, #Strings)]
		end
		completedCodes[i] = 'https://discord.gift/' .. completedNitro
		task.wait()
	end
	return completedCodes
end
