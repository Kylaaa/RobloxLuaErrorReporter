--[[
	ErrorReporter is designed to handle all of the logic of parsing information from errors,
	 and sending it to the appropriate places.
]]

local configuration = require(script.Parent.Parent.Config)

-- constants
local GAME_VERSION = configuration.GAME_VERSION
local DEBUG_REPORTER = configuration.DEBUG_REPORTER
local REPORT_TO_PLAYFAB = configuration.REPORT_TO_PLAYFAB
local REPORT_TO_GOOGLE_ANALYTICS = configuration.REPORT_TO_GOOGLE_ANALYTICS
local PRINT_SUCCESSFUL_GOOGLE_ANALYTICS = configuration.PRINT_SUCCESSFUL_GOOGLE_ANALYTICS
local PRINT_SUCCESSFUL_PLAYFAB = configuration.PRINT_SUCCESSFUL_PLAYFAB

-- reporters
local Src = script.Parent
local ReporterGoogleAnalytics = require(Src.Reporters.GoogleAnalytics)
local ReporterPlayFab = require(Src.Reporters.PlayFab)

-- helpers
local Networking = require(Src.Http.Networking)
local getFullPath = require(Src.Util.getFullPath)



-- helper functions
local function removePlayerNameFromStack(stack)
	-- in order to generalize the data so that errors are properly grouped,
	--  we must strip out any personal information from the callstack.
	if not type(stack) == "string" then
		warn(string.format("Expected stack to be a string, received : %s", type(stack)))
		return tostring(stack)
	end

	local sanitizedStack = string.gsub(stack, "Players%.[^.]+%.", "Players.<Player>.")
	return sanitizedStack
end



local ErrorReporter = {}
ErrorReporter.__index = ErrorReporter

function ErrorReporter.new(networkingImpl)
	if not networkingImpl then
		networkingImpl = Networking.new()
	end

	local er = {
		-- reporter implementations
		_googleAnalyticsReporter = ReporterGoogleAnalytics.new({
			networking = networkingImpl,
		}),
		_playFabReporter = ReporterPlayFab.new(),
	}
	setmetatable(er, ErrorReporter)

	return er
end


-- message : (string) the text of error thrown
-- stack : (string) the debug.traceback() of the where the error originated
-- origin : (datatype) the container where the error came from
function ErrorReporter:Report(message, stack, origin)
	-- make sure that there isn't a circular loop of errors
	local success, result = pcall(function()
		if DEBUG_REPORTER then
			local debugMsg = table.concat({
				"Received Error :",
				string.format("Message : (%s) - %s", type(message), message),
				string.format("Stack : (%s) - %s", type(stack), stack),
				string.format("Origin : (%s) - %s", type(origin), getFullPath(origin)),
				"***************************",
			}, "\n")
			print(debugMsg)
		end

		-- format the message and stack
		local strMessage = removePlayerNameFromStack(message)
		local strStack = removePlayerNameFromStack(stack)
		local strOrigin = removePlayerNameFromStack(getFullPath(origin))

		-- report the error to all reporters
		if REPORT_TO_GOOGLE_ANALYTICS then
			local p = self._googleAnalyticsReporter:sendEvent(GAME_VERSION, strMessage, strStack)
			p:andThen(function()
				if PRINT_SUCCESSFUL_GOOGLE_ANALYTICS then
					print("** Successfully reported error to GoogleAnalytics **",
						"(Set Config.PRINT_SUCCESSFUL_GOOGLE_ANALYTICS to false to disable this message)")
				end
			end,
			function(err)
				warn("Error thrown while reporting to GA : ", err)
			end)
		end

		if REPORT_TO_PLAYFAB then
			local category = string.format("Errors-%s", GAME_VERSION)
			local value = {
				error = strMessage,
				stack = strMessage,
				origin = strOrigin,
			}
			self._playFabReporter:fireEvent(category, value)

			-- PlayFab will not work while testing in Studio. It will give you an error saying :
			-- `AnalyticsService can only be executed by game server.`
			-- This means that you have to be playing a published game to get any real data.
			-- But as far as this script cares, you successfully sent data to PlayFab.
			if PRINT_SUCCESSFUL_PLAYFAB then
				print("** Successfully reported error to PlayFab **",
					"(Set Config.PRINT_SUCCESSFUL_PLAYFAB to false to disable this message)")
			end
		end
	end)

	if not success then
		local warning = table.concat({
			"Error Reporter threw an error :",
			tostring(result),
			"While reporting...",
			string.format("Message : (%s) - %s", type(message), message),
			string.format("Stack : (%s) - %s", type(stack), stack),
			string.format("Origin : (%s) - %s", type(origin), tostring(origin)),
		}, "\n")
		warn(warning)
	end
end

return ErrorReporter