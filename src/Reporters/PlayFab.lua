--[[
	This object acts as a simple data validation layer for AnalyticsService's FireEvent function.

	But in order for it to work properly, make sure that you have configured
	your PlayFab account and have set up your API key in Studio.

	Be sure to follow the setup instructions here :
	https://developer.roblox.com/en-us/articles/using-the-analytics-service
]]

local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")


local PlayFabReporter = {}
PlayFabReporter.__index = PlayFabReporter

function PlayFabReporter.new(reportingService)
	if not reportingService then
		reportingService = AnalyticsService
	end

	local pfr = {
		_reportingService = reportingService
	}
	setmetatable(pfr, PlayFabReporter)

	return pfr
end

-- category : (string) the name that will appear in the PlayFab event dashboard
-- value : (table) a json blob of data that contextualizes the event being sent
function PlayFabReporter:fireEvent(category, value)
	assert(type(category) == "string", "Category must be a string")
	assert(type(value) == "table", "Value must be a json table")

	local isValidJSON = pcall(HttpService.JSONEncode, HttpService, value)
	assert(isValidJSON, "Value must be a valid json table")

	-- pass the data down to AnalyticsService
	self._reportingService:FireEvent(category, value)
end

return PlayFabReporter