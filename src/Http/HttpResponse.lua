local HttpService = game:GetService("HttpService")

local HttpResponse = {}
HttpResponse.__index = HttpResponse
HttpResponse.__tostring = function(hr)
	local success, result = pcall(HttpService.JSONEncode, HttpService, hr)
	return success and result or hr.responseBody
end

function HttpResponse.new(resBody, resCode, resTime)
	local h = {
		responseBody = resBody,
		responseCode = resCode,
		responseTime = resTime
	}
	setmetatable(h, HttpResponse)

	return h
end

return HttpResponse