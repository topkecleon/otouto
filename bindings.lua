--[[
	bindings.lua (rev. 2016/05/28)
	otouto's bindings for the Telegram bot API.
	https://core.telegram.org/bots/api
	Copyright 2016 topkecleon. Published under the AGPLv3.

	See the "Bindings" section of README.md for usage information.
]]--

local bindings = {}

local HTTPS = require('ssl.https')
local JSON = require('dkjson')
local ltn12 = require('ltn12')
local MP_ENCODE = require('multipart-post').encode

 -- Build and send a request to the API.
 -- Expecting self, method, and parameters, where method is a string indicating
 -- the API method and parameters is a key/value table of parameters with their
 -- values.
 -- Returns the table response with success. Returns false and the table
 -- response with failure. Returns false and false with a connection error.
 -- To mimic old/normal behavior, it errs if used with an invalid method.
function bindings:request(method, parameters, file)
	parameters = parameters or {}
	for k,v in pairs(parameters) do
		parameters[k] = tostring(v)
	end
	if file and next(file) ~= nil then
		local file_type, file_name = next(file)
		local file_file = io.open(file_name, 'r')
		local file_data = {
			filename = file_name,
			data = file_file:read('*a')
		}
		file_file:close()
		parameters[file_type] = file_data
	end
	if next(parameters) == nil then
		parameters = {''}
	end
	local response = {}
	local body, boundary = MP_ENCODE(parameters)
	local success = HTTPS.request{
		url = self.BASE_URL .. method,
		method = 'POST',
		headers = {
			["Content-Type"] =	"multipart/form-data; boundary=" .. boundary,
			["Content-Length"] = #body,
		},
		source = ltn12.source.string(body),
		sink = ltn12.sink.table(response)
	}
	local data = table.concat(response)
	if not success then
		print(method .. ': Connection error.')
		return false, false
	else
		local result = JSON.decode(data)
		if not result then
			return false, false
		elseif result.ok then
			return result
		else
			assert(result.description ~= 'Method not found', method .. ': Method not found.')
			return false, result
		end
	end
end

function bindings.gen(_, key)
	return function(self, params, file)
		return bindings.request(self, key, params, file)
	end
end
setmetatable(bindings, { __index = bindings.gen })

return bindings
