local weather = {}

local HTTP = require('socket.http')
HTTP.TIMEOUT = 2
local JSON = require('dkjson')
local utilities = require('otouto.utilities')

function weather:init(config)
	if not config.owm_api_key then
		print('Missing config value: owm_api_key.')
		print('weather.lua will not be enabled.')
		return
	end

	weather.triggers = utilities.triggers(self.info.username, config.cmd_pat):t('weather', true).table
	weather.doc = [[```
]]..config.cmd_pat..[[weather <location>
Returns the current weather conditions for a given location.
```]]
end

weather.command = 'weather <location>'

function weather:action(msg, config)

	local input = utilities.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			utilities.send_message(self, msg.chat.id, weather.doc, true, msg.message_id, true)
			return
		end
	end

	local coords = utilities.get_coords(input, config)
	if type(coords) == 'string' then
		utilities.send_reply(self, msg, coords)
		return
	end

	local url = 'http://api.openweathermap.org/data/2.5/weather?APPID=' .. config.owm_api_key .. '&lat=' .. coords.lat .. '&lon=' .. coords.lon

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		utilities.send_reply(self, msg, config.errors.connection)
		return
	end

	local jdat = JSON.decode(jstr)
	if jdat.cod ~= 200 then
		utilities.send_reply(self, msg, 'Error: City not found.')
		return
	end

	local celsius = string.format('%.2f', jdat.main.temp - 273.15)
	local fahrenheit = string.format('%.2f', celsius * (9/5) + 32)
	local output = '`' .. celsius .. '°C | ' .. fahrenheit .. '°F, ' .. jdat.weather[1].description .. '.`'

	utilities.send_reply(self, msg, output, true)

end

return weather
