local PLUGIN = {}

PLUGIN.doc = config.COMMAND_START .. locale.weather.command .. '\n' .. locale.weather.help

PLUGIN.triggers = {
	'^' .. config.COMMAND_START .. locale.weather.command,
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		return send_msg(msg, PLUGIN.doc)
	end

	coords = get_coords(input)
	if not coords then
		return send_msg(msg, locale.noresults)
	end

	local url = 'http://api.openweathermap.org/data/2.5/weather?lat=' .. coords.lat .. '&lon=' .. coords.lon
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, locale.conn_err)
	end
	local jdat = JSON.decode(jstr)

	local celsius = jdat.main.temp - 273.15
	local fahrenheit = tonumber(string.format("%.2f", celsius * (9/5) + 32))
	local message = jdat.name .. ': ' .. celsius .. '°C | ' .. fahrenheit .. '°F, ' .. jdat.weather[1].description .. '.'

	send_msg(msg, message)

end

return PLUGIN
