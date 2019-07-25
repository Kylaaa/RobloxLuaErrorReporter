--[[
	This file is to provide a simple place to update values that
	 this error reporter needs to be able to function properly.

	These values are only read in as constants. Changing them while the game is running
	 will not update the behaviors of the reporters.
]]


return {
	-- Game metadata
	GAME_VERSION = "0.0.1",

	-- Google Analytics values
	REPORT_TO_GOOGLE_ANALYTICS = true,
	GOOGLE_ANALYTICS_TRACKING_ID = "UA-00000000-00",
	PRINT_SUCCESSFUL_GOOGLE_ANALYTICS = true,

	-- PlayFab values
	REPORT_TO_PLAYFAB = false,
	PRINT_SUCCESSFUL_PLAYFAB = true,

	-- General behaviors
	DEBUG_HTTP = false,
	DEBUG_REPORTER = false,
}