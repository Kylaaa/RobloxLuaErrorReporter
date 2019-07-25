--[[
	Recursively step through a table and print all of its keys and values
]]

-- theObj : (variant) the table with values to print
return function(theObj)
	local function printAll(t, spaceIndex)
		if not spaceIndex then
			spaceIndex = 0
		elseif spaceIndex > 10 then
			return "... tree too deep ..."
		end
		local spacer = string.rep("  ", spaceIndex)

		local outStr
		if not t then
			outStr = "nil"
		elseif type(t) == "table" then
			local parts = {}
			table.insert(parts, "{")
			for k, v in pairs(t) do
				local substr = string.format("%s%s : %s", spacer, tostring(k), printAll(v, spaceIndex + 1))
				table.insert(parts, substr)
			end
			table.insert(parts, string.format("%s}", spacer))
			outStr = table.concat(parts, "\n")
		else
			outStr = string.format("<%s> - %s", type(t), tostring(t))
		end

		return string.format("%s", outStr)
	end

	local outString = table.concat({
		" ********************************* ",
		printAll(theObj),
		" ********************************* "
	}, "\n")
	return outString
end