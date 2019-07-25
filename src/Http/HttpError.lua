local HttpService = game:GetService("HttpService")

local HttpError = {}
HttpError.__index = HttpError
HttpError.__tostring = function(he)
	return HttpService:JSONEncode(he)
end
HttpError.ErrorCodes = {
	BadRequest = 400,
	Unauthorized = 401,
	Forbidden = 403,
	NotFound = 404,
	ServerError = 500,
}

function HttpError.new(targetUrl, errMsg, resBody, errCode, resTime)
	local h = {
		target = targetUrl,
		message = errMsg,
		responseBody = resBody,
		responseCode = errCode,
		responseTime = resTime
	}
	setmetatable(h, HttpError)

	return h
end

return HttpError
