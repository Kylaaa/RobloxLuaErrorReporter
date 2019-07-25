--[[
	A promise based Http library
]]

-- constants
local configuration = require(script.Parent.Parent.Parent.Config)
local DEBUG_HTTP = configuration.DEBUG_HTTP

-- services
local HttpService = game:GetService("HttpService")

-- helpers
local Util = script.Parent.Parent.Util
local Http = script.Parent
local HttpResponse = require(Http.HttpResponse)
local HttpError = require(Http.HttpError)
local Promise = require(Util.Promise)
local recursiveToString = require(Util.recursiveToString)


-- url : (string, read-only) copy of target url that httpRequestFunc will hit
-- httpRequestFunc : (function<dictionary>(void))
local function commonHttpHandler(url, httpRequestFunc)
	assert(type(url) == "string", "expected 'url' to be a string")
	assert(type(httpRequestFunc) == "function", "expected 'httpRequestFunc' to be a function")

	local p = Promise.new(function(resolve, reject)

		spawn(function()
			local startTime = tick()
			local success, resultDict = pcall(httpRequestFunc)
			local endTime = tick()
			local deltaMs = (endTime - startTime) * 1000

			if success then
				local body = resultDict["Body"]
				local requestSuccess = resultDict["Success"]
				local statusMsg = resultDict["StatusMessage"]
				local statusCode = resultDict["StatusCode"]

				if requestSuccess == true then
					resolve(HttpResponse.new(body, statusCode, deltaMs))
				else
					reject(HttpError.new(url, statusMsg, body, statusCode, deltaMs))
				end
			else
				-- the request timed out, or something went wrong
				reject(HttpResponse.new(url, "Unknown Error", resultDict, 500, deltaMs))
			end

			if DEBUG_HTTP then
				local msg = table.concat(
				{
					"--------------------------",
					"Fetching Url :" .. url, "",
					"Success :" .. tostring(success), "",
					"Result :", recursiveToString(resultDict),
					"--------------------------"
				}, "\n")
				print(msg)
			end
		end)
	end)

	return p
end



local Networking = {}
Networking.__index = Networking

-- httpImpl : (table, optional) a service that implements RequestAsync
function Networking.new(httpImpl)
	if not httpImpl then
		httpImpl = HttpService
	end

	local n = {
		-- some default headers
		_headers = {
			["Content-Type"] = "application/json",
		},

		-- the object that will fire the http requests
		_httpImpl = httpImpl
	}
	setmetatable(n, Networking)

	return n
end

-- url : (string)
-- customHeaders : (dictionary<string, string>, optional)
-- returns : (promise<HttpResponse/HttpError>)
function Networking:GET(url, customHeaders)
	if not customHeaders then
		customHeaders = self._headers
	end

	assert(type(url) == "string", "expected 'url' to be a string")
	assert(type(customHeaders) == "table", "expected 'customHeaders' to be a dictionary")

	local httpFunc = function()
		return self._httpImpl:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = customHeaders,
		})
	end

	return commonHttpHandler(url, httpFunc)
end


-- url : (string)
-- body : (string)
-- customHeaders : (dictionary<string, string>, optional)
-- returns : (promise<HttpResponse/HttpError>)
function Networking:POST(url, body, customHeaders)
	if not customHeaders then
		customHeaders = self._headers
	end

	assert(type(url) == "string", "expected 'url' to be a string")
	assert(type(body) == "string", "expected 'body' to be a string")
	assert(type(customHeaders) == "table", "expected 'customHeaders' to be a dictionary")

	local httpFunc = function()
		return self._httpImpl:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = customHeaders,
			Body = body,
		})
	end

	return commonHttpHandler(url, httpFunc)
end

return Networking

