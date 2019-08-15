
-- services
local ScriptContext = game:GetService("ScriptContext")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- helpers
local Src = script.Parent
local ErrorReporter = require(Src.ErrorReporter)
local ErrorObserverClient = Src.ErrorObserverClient


local er = ErrorReporter.new()
local function onError(message, stack, origin)
	er:Report(message, stack, origin)
end

-- Listen for errors fired from the server
ScriptContext.Error:Connect(onError)

-- Also listen for errors fired from the client by cloning a LocalScript
--  into StarterPlayerScripts that will fire a RemoteEvent when a clientside error occurs.
local cer = ErrorObserverClient:Clone()
cer.Parent = StarterPlayer.StarterPlayerScripts

-- check that we're not accidentally colliding with an existing name
assert(ReplicatedStorage:FindFirstChild("ErrorReporting", false) == nil,
	"Error Reporter expected to create a folder named 'ErrorReporting', but something already had that name")
local errFolder = Instance.new("Folder", ReplicatedStorage)
errFolder.Name = "ErrorReporting"

local errEvent = Instance.new("RemoteEvent", errFolder)
errEvent.Name = "ClientErrorEvent"

errEvent.OnServerEvent:Connect(function(_, message, stack, origin)
	onError(message, stack, origin)
end)



-- also check that the source code is in a safe place
local host = script.Parent.Parent.Parent.ClassName
if host ~= "ServerScriptService" then
	warn("This module contains sensitive information. It would be wise to place it ServerScriptService")
end