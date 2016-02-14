if not config.owm_api_key then
	print('Missing config value: owm_api_key.')
	print('weather.lua will not be enabled.')
	return
end

local command = 'weather <location>'
local doc = [[```
/weather <location>
Returns the current weather conditions for a given location.
```]]

local triggers = {
	'^/weather[@'..bot.username..']*'
}

local action = function(msg)

	local input = msg.text:input()
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			sendMessage(msg.chat.id, doc, true, msg.message_id, true)
			return
		end
	end

	local coords = get_coords(input)
	if type(coords) == 'string' then
		sendReply(msg, coords)
		return
	end

	local url = 'http://api.openweathermap.org/data/2.5/weather?APPID=' .. config.owm_api_key .. '&lat=' .. coords.lat .. '&lon=' .. coords.lon

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		sendReply(msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.cod ~= 200 then
		sendReply(msg, 'Error: City not found.')
		return
	end

	local celsius = string.format('%.2f', jdat.main.temp - 273.15)
	local fahrenheit = string.format('%.2f', celsius * (9/5) + 32)
	local message = celsius .. '°C | ' .. fahrenheit .. '°F, ' .. jdat.weather[1].description .. '.'

	sendReply(msg, message)

end

return {
	action = action,
	triggers = triggers,
	doc = doc,
	command = command
}
