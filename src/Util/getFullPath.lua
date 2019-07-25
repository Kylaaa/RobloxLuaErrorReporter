--[[
	Recursively trace the list of parents.
]]

-- theObj : (variant) the table with values to print
return function(theObj)
	local pathToObject = theObj.Name

	local currentObj = theObj
	while currentObj.Parent ~= nil do
		pathToObject = string.format("%s.%s", currentObj.Parent.Name, pathToObject)
		currentObj = currentObj.Parent
	end

	return pathToObject
end