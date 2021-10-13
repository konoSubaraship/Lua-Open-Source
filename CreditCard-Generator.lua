function generateCard()
	local cardFormat = '%s | %s | %s | %s'
	local function generateNumber()
		local completedString = ''
		for i = 1, 4 do 
			completedString = completedString .. tostring(math.random(1000, 9999))
		end
		return completedString
	end
	local function generateDate()
		local generateDay = math.random(1, 30)
		local completedDate = ''
		if generateDay < 10 then 
			completedDate = '0' .. tostring(generateDay)
		else 
			completedDate = tostring(generateDate)
		end
		return completedDate
	end
	local function generateYear() 
		return tostring(math.random(2021, 2026))
	end
	local function generateCCV()
		return tostring(math.random(300, 600))
	end
	return cardFormat:format(generateNumber(), generateDate(), generateYear(), generateCCV())
end
