--[[
	GoogleAnalytics Reporter is designed to provide a simple interface for
	your GoogleAnalytics dashboard.
]]

local configuration = require(script.Parent.Parent.Parent.Config)

-- constants
local VERSION = 1
local PROPERTY_ID = configuration.GOOGLE_ANALYTICS_TRACKING_ID
local PLACE_ID = game.PlaceId

-- services
local HttpService = game:GetService("HttpService")


-- networking : (table) our http handler for making POST requests
-- trackingId : (string)
-- clientId : (string)
-- userId : (string)
-- eventArgs : (table) event specific arguments
local function sendReport(networking, trackingId, clientId, userId, eventArgs)
	local url = "https://www.google-analytics.com/collect"
	--local url = "https://www.google-analytics.com/debug/collect"

	-- sanitize some input
	local function exists(variableName, value)
		local wasFound = (value ~= nil)
		if not wasFound then
			warn("Google Analytics cannot send reports without a " .. variableName)
		end
		return wasFound
	end
	if not (exists("tracking ID", trackingId) and
		exists("userId", userId) and
		exists("clientId", clientId) and
		exists("event arguments", eventArgs)) then
		return
	end

	local params = {}
	for k,v in pairs(eventArgs) do
		table.insert(params, string.format("%s=%s",k,v))
	end

	-- add some required arguments
	table.insert(params, string.format("v=%d", VERSION))		-- version
	table.insert(params, string.format("tid=%s", trackingId))	-- property Id
	table.insert(params, string.format("ds=%s", PLACE_ID))		-- data source
	table.insert(params, string.format("cid=%s", clientId))		-- guid to identify this specific client
	table.insert(params, string.format("uid=%s", userId))		-- unique, anonymous user id. This should be last


	-- construct the post body data
	local paramString = table.concat(params, "&")

	-- report the event to GA
	return networking:POST(url, paramString)
end


-- public api
local GAReporter = {}
GAReporter.__index = GAReporter

-- dependencies : (dictionary<string, table>) a map of requirements
-- dependencies.networking : (table) an object that implements POST and returns a promise
function GAReporter.new(dependencies)
	local reporter = {
		-- trackingId sends the data to the right GA property.
		trackingId = PROPERTY_ID,

		-- userId is meant to help identify recurring users,
		-- If you plan on using GAReporter on a per-client basis, you should set this value
		userId = HttpService:GenerateGUID(),

		-- clientId is meant to identify a given session that data is coming from.
		clientId = HttpService:GenerateGUID(),

		-- our HTTP handler
		_networking = dependencies.networking,
	}
	setmetatable(reporter, GAReporter)

	return reporter
end

function GAReporter:setUserId(userId)
	assert(type(userId) == "string", "userId must be a string")
	self.userId = userId
end

-- context : (string)
-- action : (string)
-- label : (string)
-- value : (number, optional)
function GAReporter:sendEvent(context, action, label, value)
	assert(self.trackingId ~= "UA-00000000-00", "** YOU HAVE NOT YET SET YOUR GOOGLE ANALYTICS TRACKING ID IN CONFIG **")

	-- data validation
	local function validateStringInput(var, name, length)
		if type(var) == "string" then
			if #var > length then
				warn(string.format("%s cannot be longer than %d chars", name, length))
				var = var:sub(1, length - 1)
				warn(string.format("%s  has been truncated to %d chars", name, #var))
			end
		else
			error(string.format("%s must be a string", name))
		end
	end

	validateStringInput(context, "Context", 150)
	validateStringInput(action, "Action", 500)
	validateStringInput(label, "Label", 500)

	if value then
		assert(type(value) == "number", "Value must be a number")
		assert(value < 0, "Value must be greater than 0")
	end

	-- construct some args
	local args = {}
	args["t"] = "event"
	args["ec"] = context
	args["ea"] = action
	if label then
		args["el"] = label
	end
	if value then
		args["ev"] = value
	end

	return sendReport(self._networking, self.trackingId, self.clientId, self.userId, args)
end

--[[function GAReporter:sendPageView(...)
	assert(self.trackingId ~= "UA-00000000-00", "YOU HAVE NOT YET SET YOUR GOOGLE ANALYTICS TRACKING ID")
	-- look this up : https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
end]]

return GAReporter