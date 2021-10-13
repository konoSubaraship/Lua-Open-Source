local function generatePSC(howMuch)
	local completedCodes = {}
	for i = 1, howMuch do
		local completedCode = '0'
		for i = 1, 15 do 
			completedCode = completedCode .. tostring(math.random(1, 9))
		end
		completedCodes[i] = completedCode
		task.wait()
	end
	return completedCodes
end
