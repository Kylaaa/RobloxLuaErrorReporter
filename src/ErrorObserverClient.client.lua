--[[
	This LocalScript is designed to simply listen for errors,
	 then report them back to the server so that the ErrorReporter can handle them.
]]

-- services
local ScriptContext = game:GetService("ScriptContext")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- helpers
local function printWarningMessage(target)
	local msg = table.concat({
		string.format("Could not locate %s.", target),
		string.format("Clientside error reporting disabled for %s", Players.LocalPlayer.Name),
	}, " ")
	warn(msg)
end

-- find the error signal by navigating into the folder in ReplicatedStorage
local ErrorFolder = ReplicatedStorage:FindFirstChild("ErrorReporting", false)
if not ErrorFolder then
	printWarningMessage("ReplicatedStorage.ErrorReporting")
	return
end

local ClientErrorEvent = ErrorFolder:FindFirstChild("ClientErrorEvent")
if not ClientErrorEvent then
	printWarningMessage("ReplicatedStorage.ErrorReporting.ClientErrorEvent")
	return
end

-- simply pass the error up to the server. The server will strip out any player information.
ScriptContext.Error:Connect(function(message, stack, origin)
	ClientErrorEvent:FireServer(message, stack, origin)
end)